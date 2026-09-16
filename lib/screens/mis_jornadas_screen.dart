import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inscripcion_controller.dart';
import '../controllers/jornada_controller.dart';
import '../models/jornada.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/estado_progreso_badge.dart';
import 'crear_jornada_screen.dart';

class MisJornadasScreen extends ConsumerWidget {
  const MisJornadasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Inicia sesión para ver tus jornadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final inscritasAsync = ref.watch(jornadasInscritasProvider(user.id));
    final organizadasAsync = ref.watch(jornadasOrganizadasProvider(user.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Jornadas'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Inscrito'),
              Tab(text: 'Organizadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Jornadas inscritas
            inscritasAsync.when(
              data: (jornadas) {
                if (jornadas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No estás inscrito en ninguna jornada aún.\n¡Explora el mapa y apúntate a una causa!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jornadas.length,
                  itemBuilder: (context, index) {
                    final j = jornadas[index];
                    return _JornadaItemCard(jornada: j, esInscritoTab: true, userId: user.id);
                  },
                );
              },
              loading: () => const SkeletonList(),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),

            // Pestaña 2: Jornadas organizadas
            organizadasAsync.when(
              data: (jornadas) {
                if (jornadas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No has organizado ninguna jornada aún.\n¡Crea una y lidera el cambio comunitario!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jornadas.length,
                  itemBuilder: (context, index) {
                    final j = jornadas[index];
                    return _JornadaItemCard(jornada: j, esInscritoTab: false, userId: user.id);
                  },
                );
              },
              loading: () => const SkeletonList(),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ],
        ),
      ),
    );
  }
}

class _JornadaItemCard extends ConsumerWidget {
  final Jornada jornada;
  final bool esInscritoTab;
  final String userId;

  const _JornadaItemCard({
    required this.jornada,
    required this.esInscritoTab,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    jornada.categoria == 'Otro' && jornada.categoriaPersonalizada != null
                        ? jornada.categoriaPersonalizada!
                        : jornada.categoria,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                EstadoProgresoBadge(estadoProgreso: jornada.estadoProgreso),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${jornada.fecha} • ${jornada.hora}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (!esInscritoTab)
                  PopupMenuButton<String>(
                    onSelected: (nuevoEstado) async {
                      try {
                        await ref.read(jornadaControllerProvider.notifier).actualizarEstadoProgreso(jornada.id, nuevoEstado);
                        ref.invalidate(jornadasOrganizadasProvider(userId));
                        ref.invalidate(jornadasStreamProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Estado de progreso actualizado')),
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'pendiente', child: Text('🔴 Pendiente')),
                      const PopupMenuItem(value: 'en_proceso', child: Text('🟡 En proceso')),
                      const PopupMenuItem(value: 'completada', child: Text('🟢 Completada')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Cambiar estado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              jornada.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              jornada.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    jornada.direccionReferencia,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    try {
                      final text = '¡Únete a la jornada comunitaria "${jornada.titulo}"!\n📍 Categoría: ${jornada.categoria}\n📅 Fecha: ${jornada.fecha} a las ${jornada.hora}\n📌 Lugar: ${jornada.direccionReferencia}\n\n¡Participa con CausApp!';
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
                  label: const Text('Compartir', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                if (esInscritoTab)
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(inscripcionControllerProvider.notifier).cancelarInscripcion(jornada.id, userId);
                      ref.invalidate(jornadasInscritasProvider(userId));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inscripción cancelada')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                    label: const Text('Cancelar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearJornadaScreen(jornadaParaEditar: jornada),
                            ),
                          ).then((_) {
                            ref.invalidate(jornadasOrganizadasProvider(userId));
                            ref.invalidate(jornadasStreamProvider);
                          });
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2E7D32)),
                        label: const Text('Editar', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
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
                              ref.invalidate(jornadasOrganizadasProvider(userId));
                              ref.invalidate(jornadasStreamProvider);
                              if (context.mounted) {
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
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
