import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../controllers/recurso_controller.dart';
import '../widgets/skeleton_loader.dart';
import 'publicar_recurso_screen.dart';
import 'detalle_recurso_screen.dart';

class RecursosScreen extends ConsumerWidget {
  const RecursosScreen({super.key});

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return const Color(0xFF2E7D32); // Verde
      case 'prestado':
        return const Color(0xFFF9A825); // Amarillo
      case 'no_disponible':
        return const Color(0xFFD32F2F); // Rojo
      default:
        return Colors.grey;
    }
  }

  String _getTextoEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return 'Disponible';
      case 'prestado':
        return 'Prestado';
      case 'no_disponible':
        return 'No disponible';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursosAsync = ref.watch(recursoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamo de Herramientas'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: recursosAsync.when(
        data: (recursos) {
          if (recursos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handyman_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay herramientas o artículos publicados.\n¡Comparte herramientas con la comunidad!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF2E7D32),
            onRefresh: () async {
              await ref.read(recursoControllerProvider.notifier).recargar();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recursos.length,
              itemBuilder: (context, index) {
                final recurso = recursos[index];
                final colorEstado = _getColorEstado(recurso.estado);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleRecursoScreen(recurso: recurso),
                        ),
                      );
                    },
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
                                  'Cantidad: ${recurso.cantidad}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: const Color(0xFF2E7D32),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorEstado.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorEstado),
                                ),
                                child: Text(
                                  _getTextoEstado(recurso.estado),
                                  style: TextStyle(color: colorEstado, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            recurso.nombreArticulo,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recurso.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Ofrecido por miembro de la comunidad',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2E7D32)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const SkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = ref.read(currentUserProvider);
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión para publicar un artículo.')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicarRecursoScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
