import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../controllers/recurso_controller.dart';
import '../controllers/jornada_controller.dart';

class PublicarRecursoScreen extends ConsumerStatefulWidget {
  final String? jornadaIdPreseleccionada;

  const PublicarRecursoScreen({super.key, this.jornadaIdPreseleccionada});

  @override
  ConsumerState<PublicarRecursoScreen> createState() => _PublicarRecursoScreenState();
}

class _PublicarRecursoScreenState extends ConsumerState<PublicarRecursoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');
  final _descripcionController = TextEditingController();

  String _estadoSeleccionado = 'disponible';
  final Map<String, String> _estados = {
    'disponible': 'Disponible',
    'prestado': 'Prestado',
    'no_disponible': 'No disponible',
  };

  String? _jornadaIdSeleccionada;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _jornadaIdSeleccionada = widget.jornadaIdPreseleccionada;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 1;

      await ref.read(recursoControllerProvider.notifier).publicarRecurso(
            jornadaId: _jornadaIdSeleccionada,
            usuarioId: user.id,
            nombreArticulo: _nombreController.text.trim(),
            cantidad: cantidad,
            descripcion: _descripcionController.text.trim(),
            estado: _estadoSeleccionado,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Artículo publicado con éxito!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jornadasAsync = ref.watch(jornadasStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofrecer Herramienta / Artículo'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalles del Artículo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del artículo (ej. Escoba, Pala, Carretilla)',
                  prefixIcon: Icon(Icons.handyman, color: Color(0xFF2E7D32)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.format_list_numbered, color: Color(0xFF2E7D32)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Cantidad válida requerida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Condiciones de préstamo',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _estadoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Estado inicial',
                  prefixIcon: Icon(Icons.flag_outlined, color: Color(0xFF2E7D32)),
                ),
                items: _estados.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _estadoSeleccionado = val);
                },
              ),
              const SizedBox(height: 16),
              jornadasAsync.when(
                data: (jornadas) {
                  return DropdownButtonFormField<String?>(
                    initialValue: _jornadaIdSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Vincular a Jornada (Opcional)',
                      prefixIcon: Icon(Icons.event, color: Color(0xFF2E7D32)),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Ninguna (Ofrecer a la comunidad en general)'),
                      ),
                      ...jornadas.map((j) {
                        return DropdownMenuItem<String?>(
                          value: j.id,
                          child: Text(j.titulo, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _jornadaIdSeleccionada = val);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _publicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Publicar Artículo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
