import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/reporte.dart';
import '../models/comentario.dart';
import '../models/seguimiento.dart';
import '../controllers/reporte_controller.dart';
import '../widgets/animated_background.dart';
import 'directorio_autoridades_screen.dart';

class DetalleReporteScreen extends ConsumerStatefulWidget {
  final Reporte reporte;

  const DetalleReporteScreen({super.key, required this.reporte});

  @override
  ConsumerState<DetalleReporteScreen> createState() => _DetalleReporteScreenState();
}

class _DetalleReporteScreenState extends ConsumerState<DetalleReporteScreen> {
  late Reporte _currentReporte;
  bool _isApoyando = false;
  bool _isSupported = false;
  bool _isLider = false;
  bool _isLoadingExtra = true;

  List<Comentario> _comentarios = [];
  List<Seguimiento> _seguimientos = [];
  final _comentarioController = TextEditingController();
  bool _isEnviandoComentario = false;

  @override
  void initState() {
    super.initState();
    _currentReporte = widget.reporte;
    _cargarDatosExtra();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosExtra() async {
    final repo = ref.read(reporteRepositoryProvider);
    final supported = await repo.isSupportedByUser(_currentReporte.id);
    if (!mounted) return;
    final lider = await repo.isCurrentUserLider();
    if (!mounted) return;
    final comentarios = await repo.obtenerComentarios(_currentReporte.id);
    if (!mounted) return;
    final seguimientos = await repo.obtenerSeguimientos(_currentReporte.id);
    if (!mounted) return;

    setState(() {
      _isSupported = supported;
      _isLider = lider;
      _comentarios = comentarios;
      _seguimientos = seguimientos;
      _isLoadingExtra = false;
    });
  }

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

  Future<void> _toggleApoyar() async {
    setState(() => _isApoyando = true);
    try {
      final repo = ref.read(reporteRepositoryProvider);
      final nuevoConteo = await repo.toggleApoyarReporte(_currentReporte.id);
      if (!mounted) return;
      final supportedNow = await repo.isSupportedByUser(_currentReporte.id);
      if (!mounted) return;
      
      setState(() {
        _currentReporte = _currentReporte.copyWith(apoyos: nuevoConteo);
        _isSupported = supportedNow;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(supportedNow ? '¡Apoyo registrado!' : 'Has quitado tu apoyo.'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isApoyando = false);
    }
  }

  Future<void> _cambiarEstadoLider(String nuevoEstado) async {
    try {
      await ref.read(reporteControllerProvider.notifier).cambiarEstado(_currentReporte.id, nuevoEstado);
      if (!mounted) return;
      setState(() {
        _currentReporte = _currentReporte.copyWith(estado: nuevoEstado);
      });
      await _cargarDatosExtra();
      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado correctamente por líder.'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isEnviandoComentario = true);
    try {
      final repo = ref.read(reporteRepositoryProvider);
      await repo.agregarComentario(_currentReporte.id, texto);
      if (!mounted) return;
      _comentarioController.clear();
      final comentarios = await repo.obtenerComentarios(_currentReporte.id);
      if (!mounted) return;
      setState(() {
        _comentarios = comentarios;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al comentar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnviandoComentario = false);
    }
  }

  void _compartirReporte() {
    final mensaje = '¡Ayuda a la comunidad! Reporte vecinal en Colonia Matilde:\n'
        'Categoría: ${_currentReporte.categoria}\n'
        'Descripción: ${_currentReporte.descripcion}\n'
        'Estado: ${_getTextoEstado(_currentReporte.estado)}\n'
        'Apoyos: ${_currentReporte.apoyos}\n'
        '¡Unidos por una mejor colonia!';
    Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _getColorEstado(_currentReporte.estado);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentReporte.categoria),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirReporte,
            tooltip: 'Compartir reporte',
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentReporte.fotos.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentReporte.fotos.length,
                    itemBuilder: (context, index) {
                      final foto = _currentReporte.fotos[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          image: DecorationImage(
                            image: foto.startsWith('http')
                                ? NetworkImage(foto) as ImageProvider
                                : FileImage(File(foto)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      _currentReporte.categoria,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Text(
                      _getTextoEstado(_currentReporte.estado),
                      style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Descripción del problema:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                _currentReporte.descripcion,
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ubicación GPS (Colonia Matilde)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${_currentReporte.latitud.toStringAsFixed(4)}, Lon: ${_currentReporte.longitud.toStringAsFixed(4)}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Panel de Líder para cambiar Estado
              if (_isLider) ...[
                Card(
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
                            SizedBox(width: 8),
                            Text(
                              'Panel de Líder: Cambiar Estado',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: ['pendiente', 'en_seguimiento', 'canalizado', 'resuelto'].map((st) {
                            final isCurrent = _currentReporte.estado == st;
                            return ChoiceChip(
                              label: Text(_getTextoEstado(st)),
                              selected: isCurrent,
                              selectedColor: const Color(0xFF2E7D32),
                              labelStyle: TextStyle(color: isCurrent ? Colors.white : Colors.black87),
                              onSelected: (selected) {
                                if (selected && !isCurrent) {
                                  _cambiarEstadoLider(st);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botones de Apoyo y Autoridades
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isApoyando ? null : _toggleApoyar,
                      icon: Icon(_isSupported ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                      label: Text(_isSupported ? 'Apoyado (${_currentReporte.apoyos})' : 'Me afecta (${_currentReporte.apoyos})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSupported ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DirectorioAutoridadesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance, color: Color(0xFF2E7D32)),
                      label: const Text('Autoridades', style: TextStyle(color: Color(0xFF2E7D32))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Historial de Seguimientos (Líderes)
              const Text(
                'Historial de Seguimiento (Líderes)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _isLoadingExtra
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32))))
                  : (_seguimientos.isEmpty
                      ? Text('No hay registros de seguimiento aún.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
                      : Column(
                          children: _seguimientos.map((seg) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.timeline, color: Color(0xFF2E7D32)),
                                  title: Text('Estado: ${_getTextoEstado(seg.estadoNuevo)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(seg.nota, style: const TextStyle(fontSize: 12)),
                                  trailing: Text('${seg.createdAt.day}/${seg.createdAt.month}/${seg.createdAt.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ),
                              )).toList(),
                        )),
              const SizedBox(height: 24),

              // Sección de Comentarios
              const Text(
                'Comentarios Vecinales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _isLoadingExtra
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32))))
                  : (_comentarios.isEmpty
                      ? Text('Sé el primero en dejar un comentario en este reporte.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
                      : Column(
                          children: _comentarios.map((c) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.texto, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year} ${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                        )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isEnviandoComentario ? null : _enviarComentario,
                    icon: _isEnviandoComentario
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
