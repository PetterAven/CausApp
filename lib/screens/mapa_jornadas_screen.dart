import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/auth_controller.dart';
import '../controllers/jornada_controller.dart';
import '../controllers/inscripcion_controller.dart';
import '../models/jornada.dart';

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

  // Mostrar tarjeta / bottom sheet al tocar un marcador
  void _mostrarDetalleJornada(BuildContext context, Jornada jornada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          // Mapa de Google Maps
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : jornadasAsync.when(
                  data: (jornadas) {
                    // Filtrar jornadas si hay categoría seleccionada
                    final jornadasFiltradas = (_categoriaFiltroSeleccionada == null || _categoriaFiltroSeleccionada == 'Todas')
                        ? jornadas
                        : jornadas.where((j) => j.categoria == _categoriaFiltroSeleccionada).toList();

                    final Set<Marker> markers = jornadasFiltradas.map((jornada) {
                      return Marker(
                        markerId: MarkerId(jornada.id),
                        position: LatLng(jornada.latitud, jornada.longitud),
                        infoWindow: InfoWindow(
                          title: jornada.titulo,
                          snippet: '${jornada.categoria} - ${jornada.fecha}',
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
                      markers: markers,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error al cargar mapa: $e')),
                ),

          // Filtros por categoría en la parte superior
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoriasFiltro.length,
                itemBuilder: (context, index) {
                  final cat = _categoriasFiltro[index];
                  final isSelected = (_categoriaFiltroSeleccionada == null && cat == 'Todas') ||
                      (_categoriaFiltroSeleccionada == cat);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(jornadaControllerProvider.notifier).recargar();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

// Widget auxiliar para el BottomSheet de detalle de jornada e inscripción
class _JornadaBottomsheetContent extends ConsumerWidget {
  final Jornada jornada;

  const _JornadaBottomsheetContent({super.key, required this.jornada});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final inscritosCountAsync = ref.watch(inscritosCountProvider(jornada.id));
    
    final estaInscritoAsync = user != null
        ? ref.watch(estaInscritoProvider((jornadaId: jornada.id, voluntarioId: user.id)))
        : const AsyncValue.data(false);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  jornada.categoria == 'Otro' && jornada.categoriaPersonalizada != null
                      ? jornada.categoriaPersonalizada!
                      : jornada.categoria,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
              Text(
                '${jornada.fecha} • ${jornada.hora}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            jornada.titulo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            jornada.descripcion,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  jornada.direccionReferencia,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cupos / inscritos
          inscritosCountAsync.when(
            data: (count) {
              final cupoStr = jornada.cupoVoluntarios != null ? ' de ${jornada.cupoVoluntarios}' : '';
              return Text(
                'Voluntarios inscritos: $count$cupoStr',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              );
            },
            loading: () => const Text('Cargando inscritos...'),
            error: (_, __) => const Text('Inscritos: --'),
          ),
          const SizedBox(height: 24),

          // Botón de Apuntarse / Cancelar Inscripción
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
                    // Refrescar providers de conteo e inscripción
                    ref.invalidate(inscritosCountProvider(jornada.id));
                    ref.invalidate(estaInscritoProvider((jornadaId: jornada.id, voluntarioId: user.id)));
                    ref.invalidate(jornadasInscritasProvider(user.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inscrito ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    inscrito ? 'Cancelar Inscripción' : 'Apuntarme',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error al verificar inscripción'),
            ),
          ] else ...[
            const Text(
              'Inicia sesión para poder apuntarte a esta jornada.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
