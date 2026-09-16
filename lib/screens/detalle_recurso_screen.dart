import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../controllers/recurso_controller.dart';
import '../models/recurso.dart';
import '../models/mensaje_recurso.dart';

class DetalleRecursoScreen extends ConsumerStatefulWidget {
  final Recurso recurso;

  const DetalleRecursoScreen({super.key, required this.recurso});

  @override
  ConsumerState<DetalleRecursoScreen> createState() => _DetalleRecursoScreenState();
}

class _DetalleRecursoScreenState extends ConsumerState<DetalleRecursoScreen> {
  final _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para enviar mensajes.')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref.read(recursoControllerProvider.notifier).enviarMensaje(
            recursoId: widget.recurso.id,
            usuarioId: user.id,
            mensaje: texto,
          );
      _mensajeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje enviado al propietario'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar mensaje: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    try {
      await ref.read(recursoControllerProvider.notifier).actualizarEstado(widget.recurso.id, nuevoEstado);
      ref.invalidate(recursosProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado correctamente'), backgroundColor: Color(0xFF2E7D32)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return const Color(0xFF2E7D32);
      case 'prestado':
        return const Color(0xFFF9A825);
      case 'no_disponible':
        return const Color(0xFFD32F2F);
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
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isPropietario = user != null && user.id == widget.recurso.usuarioId;
    final mensajesAsync = ref.watch(mensajesRecursoStreamProvider(widget.recurso.id));

    final colorEstado = _getColorEstado(widget.recurso.estado);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recurso.nombreArticulo),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        'Cantidad: ${widget.recurso.cantidad}',
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
                        _getTextoEstado(widget.recurso.estado),
                        style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.recurso.descripcion,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                ),
                if (isPropietario) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Cambiar estado (Panel de Propietario):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => _cambiarEstado('disponible'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        child: const Text('Disponible'),
                      ),
                      OutlinedButton(
                        onPressed: () => _cambiarEstado('prestado'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF9A825),
                          side: const BorderSide(color: Color(0xFFF9A825)),
                        ),
                        child: const Text('Prestado'),
                      ),
                      OutlinedButton(
                        onPressed: () => _cambiarEstado('no_disponible'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(color: Color(0xFFD32F2F)),
                        ),
                        child: const Text('No disponible'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: mensajesAsync.when(
              data: (List<MensajeRecurso> mensajes) {
                if (mensajes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No hay mensajes aún.\n¡Escribe al propietario para coordinar el préstamo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = mensajes[index];
                    final esMio = user != null && msg.usuarioId == user.id;

                    return Align(
                      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: esMio ? const Color(0xFF2E7D32).withValues(alpha: 0.15) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.mensaje,
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.fecha.hour.toString().padLeft(2, '0')}:${msg.fecha.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
              error: (e, _) => Center(child: Text('Error al cargar chat: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2E7D32),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _isSending ? null : _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
