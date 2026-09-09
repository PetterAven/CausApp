import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inscripcion_controller.dart';
import '../models/jornada.dart';

class MisJornadasScreen extends ConsumerWidget {
  const MisJornadasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tus jornadas.')),
      );
    }

    final inscritasAsync = ref.watch(jornadasInscritasProvider(user.id));
    final organizadasAsync = ref.watch(jornadasOrganizadasProvider(user.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Jornadas'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
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
                  return const Center(child: Text('No estás inscrito en ninguna jornada aún.'));
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),

            // Pestaña 2: Jornadas organizadas
            organizadasAsync.when(
              data: (jornadas) {
                if (jornadas.isEmpty) {
                  return const Center(child: Text('No has organizado ninguna jornada aún.'));
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.zero,
                ),
                Text(
                  '${jornada.fecha} • ${jornada.hora}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              jornada.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              jornada.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (esInscritoTab)
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(inscripcionControllerProvider.notifier).cancelarInscripcion(jornada.id, userId);
                      ref.invalidate(jornadasInscritasProvider(userId));
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Cancelar inscripción', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
