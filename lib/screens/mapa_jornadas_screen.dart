import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/auth_controller.dart';
import '../controllers/jornada_controller.dart';
import '../controllers/inscripcion_controller.dart';
import '../models/jornada.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/estado_progreso_badge.dart';
import '../widgets/mapa_jornadas_widget.dart';
import '../widgets/animated_background.dart';
import '../widgets/satisfaccion_prompt.dart';
import 'crear_jornada_screen.dart';
import 'recursos_jornada_screen.dart';
import 'donar_screen.dart';

class MapaJornadasScreen extends ConsumerStatefulWidget {
  const MapaJornadasScreen({super.key});

  @override
  ConsumerState<MapaJornadasScreen> createState() => _MapaJornadasScreenState();
}

class _MapaJornadasScreenState extends ConsumerState<MapaJornadasScreen> {
  final MapController _mapController = MapController();
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

      _mapController.move(_initialPosition, 14);
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
      body: AnimatedBackground(
        child: Stack(
          children: [
          // Mapa de OpenStreetMap con FlutterMap
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : jornadasAsync.when(
                  data: (jornadas) {
                    try {
                      final jornadasFiltradas = (_categoriaFiltroSeleccionada == null || _categoriaFiltroSeleccionada == 'Todas')
                          ? jornadas
                          : jornadas.where((j) => j.categoria == _categoriaFiltroSeleccionada).toList();

                      final List<Marker> markers = [];
                      for (var jornada in jornadasFiltradas) {
                        try {
                          markers.add(
                            Marker(
                              point: LatLng(jornada.latitud, jornada.longitud),
                              width: 44,
                              height: 44,
                              child: GestureDetector(
                                onTap: () => _mostrarDetalleJornada(context, jornada),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Color(0xFF2E7D32),
                                  size: 44,
                                ),
                              ),
                            ),
                          );
                        } catch (_) {}
                      }

                      return MapaJornadasWidget(
                        mapController: _mapController,
                        initialCenter: _initialPosition,
                        zoom: 14,
                        markers: markers,
                      );
                    } catch (e) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Error al renderizar el mapa: ${e.toString()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
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
                      );
                    }
                  },
                  loading: () => const SkeletonList(),
                  error: (e, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar las jornadas en el mapa: ${e.toString()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
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
              EstadoProgresoBadge(estadoProgreso: jornada.estadoProgreso),
            ],
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          if (user != null && user.id == jornada.organizadorId) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel de Organizador (Estado de Progreso):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEstadoButton(context, ref, jornada, 'pendiente', 'Pendiente', const Color(0xFFD32F2F)),
                      _buildEstadoButton(context, ref, jornada, 'en_proceso', 'En Proceso', const Color(0xFFF9A825)),
                      _buildEstadoButton(context, ref, jornada, 'completada', 'Completada', const Color(0xFF2E7D32)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearJornadaScreen(jornadaParaEditar: jornada),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2E7D32)),
                        label: const Text('Editar', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Jornada'),
                              content: const Text('¿Seguro que quieres eliminar esta jornada? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            try {
                              await ref.read(jornadaControllerProvider.notifier).eliminarJornada(jornada.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Jornada eliminada correctamente'), backgroundColor: Color(0xFF2E7D32)),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              try {
                final text = '¡Únete a la jornada comunitaria "${jornada.titulo}"!\n📍 Categoría: ${jornada.categoria}\n📅 Fecha: ${jornada.fecha} a las ${jornada.hora}\n📌 Lugar: ${jornada.direccionReferencia}\n\n¡Participa y hagamos la diferencia con CausApp!';
                Share.share(text);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al compartir: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF2E7D32)),
            label: const Text('Compartir Jornada', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecursosJornadaModalScreen(jornada: jornada),
                ),
              );
            },
            icon: const Icon(Icons.handyman_outlined, size: 18, color: Color(0xFF2E7D32)),
            label: const Text('Herramientas y Préstamos para esta Jornada', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          if (jornada.aceptaDonacionesDinero || jornada.aceptaDonacionesArticulos) ...[
            if (user == null || user.id != jornada.organizadorId) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonarScreen(jornada: jornada),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite, size: 18, color: Colors.white),
                label: const Text('Donar a esta jornada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              DonacionesResumenWidget(jornadaId: jornada.id),
              const SizedBox(height: 12),
            ],
          ],
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

  Widget _buildEstadoButton(BuildContext context, WidgetRef ref, Jornada jornada, String estadoVal, String label, Color color) {
    final isSelected = jornada.estadoProgreso == estadoVal;
    return InkWell(
      onTap: () async {
        try {
          await ref.read(jornadaControllerProvider.notifier).actualizarEstadoProgreso(jornada.id, estadoVal);
          if (estadoVal == 'completada' && context.mounted) {
            SatisfaccionPrompt.verificarYMostrarSiProcede(context, ref);
          }
          ref.invalidate(jornadasStreamProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Estado actualizado a: $label'), backgroundColor: color),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
