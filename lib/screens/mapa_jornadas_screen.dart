import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/auth_controller.dart';
import '../controllers/jornada_controller.dart';
import '../controllers/inscripcion_controller.dart';
import '../models/jornada.dart';
import 'crear_jornada_screen.dart';

class MapaJornadasScreen extends ConsumerStatefulWidget {
  const MapaJornadasScreen({super.key});

  @override
  ConsumerState<MapaJornadasScreen> createState() => _MapaJornadasScreenState();
}

class _MapaJornadasScreenState extends ConsumerState<MapaJornadasScreen> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(19.432608, -99.133209);
  bool _isLoadingLocation = true;
  String? _categoriaFiltroSeleccionada; // null = Todas

  final List<String> _categoriasFiltro = ['Todas', 'Baches', 'Limpieza', 'Reforestación', 'Pintura', 'Otro'];

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionUsuario();
  }

  Future<void> _obtenerUbicacionUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition, 14),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _mostrarDetalleJornada(BuildContext context, Jornada jornada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _JornadaBottomsheetContent(jornada: jornada);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jornadasAsync = ref.watch(jornadaControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Mapa de Google Maps con manejo de errores / API Key faltante
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : jornadasAsync.when(
                  data: (jornadas) {
                    final jornadasFiltradas = (_categoriaFiltroSeleccionada == null || _categoriaFiltroSeleccionada == 'Todas')
                        ? jornadas
                        : jornadas.where((j) => j.categoria == _categoriaFiltroSeleccionada).toList();

                    final Set<Marker> markers = jornadasFiltradas.map((jornada) {
                      return Marker(
                        markerId: MarkerId(jornada.id),
                        position: LatLng(jornada.latitud, jornada.longitud),
                        infoWindow: InfoWindow(
                          title: jornada.titulo,
                          snippet: '${jornada.categoria} • ${jornada.fecha}',
                        ),
                        onTap: () => _mostrarDetalleJornada(context, jornada),
                      );
                    }).toSet();

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      markers: markers,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  error: (e, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Nota sobre el Mapa:\nAsegúrate de configurar tu API Key de Google Maps en AndroidManifest.xml e Info.plist.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.read(jornadaControllerProvider.notifier).recargar(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

          // Filtros por categoría superiores con diseño flotante elegante
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoriasFiltro.length,
                itemBuilder: (context, index) {
                  final cat = _categoriasFiltro[index];
                  final isSelected = (_categoriaFiltroSeleccionada == null && cat == 'Todas') ||
                      (_categoriaFiltroSeleccionada == cat);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                      onSelected: (selected) {
                        setState(() {
                          _categoriaFiltroSeleccionada = cat == 'Todas' ? null : cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Tarjeta flotante inferior de jornada cercana (estilo referencia)
          Positioned(
            bottom: 16,
            left: 16,
            right: 84,
            child: jornadasAsync.when(
              data: (jornadas) {
                if (jornadas.isEmpty) return const SizedBox.shrink();
                final jornada = jornadas.first;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 55,
                          height: 55,
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          child: const Icon(Icons.volunteer_activism, color: Color(0xFF2E7D32), size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Jornada cercana:',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              jornada.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 11, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text(
                                  jornada.fecha,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () => _mostrarDetalleJornada(context, jornada),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver más', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)),
                            Icon(Icons.chevron_right, size: 14, color: Color(0xFF2E7D32)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CrearJornadaScreen()),
            );
          },
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _JornadaBottomsheetContent extends ConsumerWidget {
  final Jornada jornada;

  const _JornadaBottomsheetContent({required this.jornada});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final inscritosCountAsync = ref.watch(inscritosCountProvider(jornada.id));
    
    final estaInscritoAsync = user != null
        ? ref.watch(estaInscritoProvider((jornadaId: jornada.id, voluntarioId: user.id)))
        : const AsyncValue.data(false);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  jornada.categoria == 'Otro' && jornada.categoriaPersonalizada != null
                      ? jornada.categoriaPersonalizada!
                      : jornada.categoria,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${jornada.fecha} • ${jornada.hora}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            jornada.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            jornada.descripcion,
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.place_outlined, size: 20, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    jornada.direccionReferencia,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          inscritosCountAsync.when(
            data: (count) {
              final cupoStr = jornada.cupoVoluntarios != null ? ' de ${jornada.cupoVoluntarios}' : '';
              return Row(
                children: [
                  const Icon(Icons.group_outlined, size: 20, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Voluntarios inscritos: $count$cupoStr',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 15),
                  ),
                ],
              );
            },
            loading: () => const Text('Cargando inscritos...', style: TextStyle(color: Colors.grey)),
            error: (err, st) => const Text('Inscritos: --', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          if (user != null) ...[
            estaInscritoAsync.when(
              data: (inscrito) {
                return ElevatedButton(
                  onPressed: () async {
                    if (inscrito) {
                      await ref.read(inscripcionControllerProvider.notifier).cancelarInscripcion(jornada.id, user.id);
                    } else {
                      await ref.read(inscripcionControllerProvider.notifier).inscribirse(jornada.id, user.id);
                    }
                    ref.invalidate(inscritosCountProvider(jornada.id));
                    ref.invalidate(estaInscritoProvider((jornadaId: jornada.id, voluntarioId: user.id)));
                    ref.invalidate(jornadasInscritasProvider(user.id));
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inscrito ? Colors.red.shade600 : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    inscrito ? 'Cancelar Inscripción' : 'Apuntarme como Voluntario',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
              error: (err, st) => const Text('Error al verificar inscripción', style: TextStyle(color: Colors.red)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Inicia sesión para poder apuntarte a esta jornada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
