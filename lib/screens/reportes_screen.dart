import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/reporte_controller.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/animated_background.dart';
import 'crear_reporte_screen.dart';
import 'detalle_reporte_screen.dart';
import 'directorio_autoridades_screen.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  String? _filtroCategoria;
  String? _filtroEstado;

  final List<String> _categorias = [
    'Todos',
    'Fuga de agua',
    'Basura',
    'Bache',
    'Alumbrado público',
    'Drenaje',
    'Otros',
  ];

  final List<String> _estados = [
    'Todos',
    'pendiente',
    'en_seguimiento',
    'canalizado',
    'resuelto',
  ];

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_seguimiento':
        return Colors.blue;
      case 'canalizado':
        return Colors.purple;
      case 'resuelto':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  String _getTextoEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_seguimiento':
        return 'En Seguimiento';
      case 'canalizado':
        return 'Canalizado';
      case 'resuelto':
        return 'Resuelto';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportesAsync = ref.watch(reporteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes - Colonia Matilde'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DirectorioAutoridadesScreen()),
              );
            },
            tooltip: 'Directorio de Autoridades',
          ),
        ],
      ),
      body: AnimatedBackground(
        child: Column(
          children: [
            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withValues(alpha: 0.8),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Categoría: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        ..._categorias.map((cat) {
                          final isSelected = (_filtroCategoria == null && cat == 'Todos') || _filtroCategoria == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              selectedColor: const Color(0xFF2E7D32),
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                              onSelected: (selected) {
                                setState(() {
                                  _filtroCategoria = (cat == 'Todos') ? null : cat;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        ..._estados.map((est) {
                          final label = est == 'Todos' ? 'Todos' : _getTextoEstado(est);
                          final isSelected = (_filtroEstado == null && est == 'Todos') || _filtroEstado == est;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(label, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              selectedColor: const Color(0xFF2E7D32),
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                              onSelected: (selected) {
                                setState(() {
                                  _filtroEstado = (est == 'Todos') ? null : est;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: reportesAsync.when(
                data: (reportes) {
                  final reportesFiltrados = reportes.where((r) {
                    if (_filtroCategoria != null && r.categoria != _filtroCategoria) return false;
                    if (_filtroEstado != null && r.estado != _filtroEstado) return false;
                    return true;
                  }).toList();

                  if (reportesFiltrados.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.report_problem_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay reportes registrados con estos filtros.\n¡Sé el primero en reportar un incidente en la colonia!',
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
                      await ref.read(reporteControllerProvider.notifier).recargar();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reportesFiltrados.length,
                      itemBuilder: (context, index) {
                        final reporte = reportesFiltrados[index];
                        final colorEstado = _getColorEstado(reporte.estado);
                        final fechaStr = '${reporte.createdAt.day}/${reporte.createdAt.month}/${reporte.createdAt.year}';

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
                                  builder: (context) => DetalleReporteScreen(reporte: reporte),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (reporte.fotos.isNotEmpty)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: reporte.fotos.first.startsWith('http')
                                              ? NetworkImage(reporte.fotos.first) as ImageProvider
                                              : FileImage(File(reporte.fotos.first)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                reporte.categoria,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: colorEstado.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: colorEstado),
                                              ),
                                              child: Text(
                                                _getTextoEstado(reporte.estado),
                                                style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          reporte.descripcion,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text('${reporte.apoyos} apoyos', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                              ],
                                            ),
                                            Text(fechaStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
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
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error al cargar reportes: $e\n(Asegúrate de que la tabla "reportes" esté creada en Supabase)', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearReporteScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        tooltip: 'Reportar incidente',
        child: const Icon(Icons.add_a_photo, color: Colors.white, size: 28),
      ),
    );
  }
}
