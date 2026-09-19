import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/auth_controller.dart';
import '../controllers/jornada_controller.dart';
import '../models/jornada.dart';
import '../widgets/mapa_jornadas_widget.dart';
import '../widgets/animated_background.dart';

class CrearJornadaScreen extends ConsumerStatefulWidget {
  final Jornada? jornadaParaEditar;

  const CrearJornadaScreen({super.key, this.jornadaParaEditar});

  @override
  ConsumerState<CrearJornadaScreen> createState() => _CrearJornadaScreenState();
}

class _CrearJornadaScreenState extends ConsumerState<CrearJornadaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaPersonalizadaController = TextEditingController();
  final _direccionReferenciaController = TextEditingController();
  final _cupoController = TextEditingController();
  final _herramientaController = TextEditingController();
  final _metaDonacionController = TextEditingController();
  final _articuloSolicitadoController = TextEditingController();
  final List<String> _herramientasNecesarias = [];
  final List<String> _articulosSolicitados = [];
  bool _aceptaDonacionesDinero = false;
  bool _aceptaDonacionesArticulos = false;

  String _categoriaSeleccionada = 'Limpieza';
  final List<String> _categorias = ['Baches', 'Limpieza', 'Reforestación', 'Pintura', 'Otro'];

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  LatLng _ubicacionSeleccionada = const LatLng(19.432608, -99.133209);
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.jornadaParaEditar != null) {
      final j = widget.jornadaParaEditar!;
      _tituloController.text = j.titulo;
      _descripcionController.text = j.descripcion;
      _categoriaSeleccionada = _categorias.contains(j.categoria) ? j.categoria : 'Otro';
      if (_categoriaSeleccionada == 'Otro') {
        _categoriaPersonalizadaController.text = j.categoriaPersonalizada ?? j.categoria;
      }
      try {
        final partsFecha = j.fecha.split('-');
        if (partsFecha.length == 3) {
          _fechaSeleccionada = DateTime(
            int.parse(partsFecha[0]),
            int.parse(partsFecha[1]),
            int.parse(partsFecha[2]),
          );
        }
      } catch (_) {}

      try {
        final partsHora = j.hora.split(':');
        if (partsHora.length == 2) {
          _horaSeleccionada = TimeOfDay(
            hour: int.parse(partsHora[0]),
            minute: int.parse(partsHora[1]),
          );
        }
      } catch (_) {}

      _ubicacionSeleccionada = LatLng(j.latitud, j.longitud);
      _direccionReferenciaController.text = j.direccionReferencia;
      if (j.cupoVoluntarios != null) {
        _cupoController.text = j.cupoVoluntarios.toString();
      }
      _herramientasNecesarias.addAll(j.herramientasNecesarias);
      _aceptaDonacionesDinero = j.aceptaDonacionesDinero;
      _aceptaDonacionesArticulos = j.aceptaDonacionesArticulos;
      if (j.metaDonacionDinero != null) {
        _metaDonacionController.text = j.metaDonacionDinero.toString();
      }
      _articulosSolicitados.addAll(j.articulosSolicitados);
      _isLoadingLocation = false;
    } else {
      _obtenerUbicacionActual();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaPersonalizadaController.dispose();
    _direccionReferenciaController.dispose();
    _cupoController.dispose();
    _herramientaController.dispose();
    _metaDonacionController.dispose();
    _articuloSolicitadoController.dispose();
    super.dispose();
  }

  void _agregarHerramienta() {
    final texto = _herramientaController.text.trim();
    if (texto.isNotEmpty && !_herramientasNecesarias.contains(texto)) {
      setState(() {
        _herramientasNecesarias.add(texto);
        _herramientaController.clear();
      });
    }
  }

  void _agregarArticuloSolicitado() {
    final texto = _articuloSolicitadoController.text.trim();
    if (texto.isNotEmpty && !_articulosSolicitados.contains(texto)) {
      setState(() {
        _articulosSolicitados.add(texto);
        _articuloSolicitadoController.clear();
      });
    }
  }

  Future<void> _obtenerUbicacionActual() async {
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

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _ubicacionSeleccionada = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _mapController.move(_ubicacionSeleccionada, 15);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  Future<void> _publicarJornada() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora de la jornada.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar una jornada.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final fechaStr = '${_fechaSeleccionada!.year.toString().padLeft(4, '0')}-'
          '${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-'
          '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';

      final horaStr = '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
          '${_horaSeleccionada!.minute.toString().padLeft(2, '0')}';

      int? cupo;
      if (_cupoController.text.trim().isNotEmpty) {
        cupo = int.tryParse(_cupoController.text.trim());
      }

      bool aceptaDinero = _aceptaDonacionesDinero;
      bool aceptaArticulos = _aceptaDonacionesArticulos;
      double? metaDinero;
      if (aceptaDinero && _metaDonacionController.text.trim().isNotEmpty) {
        metaDinero = double.tryParse(_metaDonacionController.text.trim());
      }
      List<String> articulos = aceptaArticulos ? List.from(_articulosSolicitados) : [];

      if (widget.jornadaParaEditar != null) {
        final jornadaActualizada = Jornada(
          id: widget.jornadaParaEditar!.id,
          organizadorId: widget.jornadaParaEditar!.organizadorId,
          titulo: _tituloController.text.trim(),
          categoria: _categoriaSeleccionada,
          categoriaPersonalizada: _categoriaSeleccionada == 'Otro'
              ? _categoriaPersonalizadaController.text.trim()
              : null,
          descripcion: _descripcionController.text.trim(),
          fecha: fechaStr,
          hora: horaStr,
          latitud: _ubicacionSeleccionada.latitude,
          longitud: _ubicacionSeleccionada.longitude,
          direccionReferencia: _direccionReferenciaController.text.trim(),
          cupoVoluntarios: cupo,
          estado: widget.jornadaParaEditar!.estado,
          estadoProgreso: widget.jornadaParaEditar!.estadoProgreso,
          herramientasNecesarias: _herramientasNecesarias,
          aceptaDonacionesDinero: aceptaDinero,
          aceptaDonacionesArticulos: aceptaArticulos,
          metaDonacionDinero: metaDinero,
          articulosSolicitados: articulos,
          createdAt: widget.jornadaParaEditar!.createdAt,
        );

        await ref.read(jornadaControllerProvider.notifier).actualizarJornada(jornadaActualizada);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Jornada actualizada exitosamente!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        await ref.read(jornadaControllerProvider.notifier).crearJornada(
              organizadorId: user.id,
              titulo: _tituloController.text.trim(),
              categoria: _categoriaSeleccionada,
              categoriaPersonalizada: _categoriaSeleccionada == 'Otro'
                  ? _categoriaPersonalizadaController.text.trim()
                  : null,
              descripcion: _descripcionController.text.trim(),
              fecha: fechaStr,
              hora: horaStr,
              latitud: _ubicacionSeleccionada.latitude,
              longitud: _ubicacionSeleccionada.longitude,
              direccionReferencia: _direccionReferenciaController.text.trim(),
              cupoVoluntarios: cupo,
              herramientasNecesarias: _herramientasNecesarias,
              aceptaDonacionesDinero: aceptaDinero,
              aceptaDonacionesArticulos: aceptaArticulos,
              metaDonacionDinero: metaDinero,
              articulosSolicitados: articulos,
            );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Jornada publicada exitosamente!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('Error al publicar jornada: $e\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jornadaParaEditar != null ? 'Editar Jornada Comunitaria' : 'Crear Jornada Comunitaria'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalles de la Iniciativa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la jornada',
                  prefixIcon: Icon(Icons.title, color: Color(0xFF2E7D32)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF2E7D32)),
                ),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoriaSeleccionada = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_categoriaSeleccionada == 'Otro') ...[
                TextFormField(
                  controller: _categoriaPersonalizadaController,
                  decoration: const InputDecoration(
                    labelText: 'Especifica la categoría',
                  ),
                  validator: (value) => _categoriaSeleccionada == 'Otro' && (value == null || value.isEmpty)
                      ? 'Escribe la categoría'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarFecha(context),
                      icon: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                      label: Text(
                        _fechaSeleccionada == null
                            ? 'Elegir Fecha'
                            : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                        style: TextStyle(color: _fechaSeleccionada == null ? Colors.grey.shade700 : Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarHora(context),
                      icon: const Icon(Icons.access_time, color: Color(0xFF2E7D32)),
                      label: Text(
                        _horaSeleccionada == null
                            ? 'Elegir Hora'
                            : _horaSeleccionada!.format(context),
                        style: TextStyle(color: _horaSeleccionada == null ? Colors.grey.shade700 : Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Ubicación en el Mapa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mueve el mapa para colocar el marcador en el punto exacto de la jornada.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                      : Stack(
                          children: [
                            MapaJornadasWidget(
                              mapController: _mapController,
                              initialCenter: _ubicacionSeleccionada,
                              zoom: 15,
                              onPositionChanged: (camera, hasGesture) {
                                if (hasGesture) {
                                  setState(() {
                                    _ubicacionSeleccionada = camera.center;
                                  });
                                }
                              },
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 32),
                                child: Icon(
                                  Icons.location_pin,
                                  color: Color(0xFF2E7D32),
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionReferenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de dirección (ej. Frente al parque central)',
                  prefixIcon: Icon(Icons.place_outlined, color: Color(0xFF2E7D32)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
               TextFormField(
                controller: _cupoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cupo máximo de voluntarios (opcional)',
                  prefixIcon: Icon(Icons.group_outlined, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Herramientas o Insumos Necesarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Agrega los materiales que los voluntarios deberían llevar (ej. Palas, Guantes).',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _herramientaController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la herramienta o insumo',
                        prefixIcon: Icon(Icons.handyman_outlined, color: Color(0xFF2E7D32)),
                      ),
                      onFieldSubmitted: (_) => _agregarHerramienta(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _agregarHerramienta,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
               if (_herramientasNecesarias.isNotEmpty)
                 Wrap(
                   spacing: 8,
                   runSpacing: 4,
                   children: _herramientasNecesarias.map((herramienta) {
                     return InputChip(
                       label: Text(herramienta),
                       backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                       labelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                       deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF2E7D32)),
                       onDeleted: () {
                         setState(() {
                           _herramientasNecesarias.remove(herramienta);
                         });
                       },
                     );
                   }).toList(),
                 ),
               const SizedBox(height: 24),
               const Text(
                 'Donaciones para la Jornada',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
               ),
               const SizedBox(height: 4),
               const Text(
                 'Configura si esta iniciativa acepta apoyo económico o de insumos.',
                 style: TextStyle(fontSize: 13, color: Colors.grey),
               ),
               const SizedBox(height: 12),
               SwitchListTile(
                 title: const Text('Aceptar donaciones de dinero', style: TextStyle(fontWeight: FontWeight.w600)),
                 subtitle: const Text('Permite que los voluntarios aporten fondos monetarios'),
                 value: _aceptaDonacionesDinero,
                 activeThumbColor: const Color(0xFF2E7D32),
                 contentPadding: EdgeInsets.zero,
                 onChanged: (val) => setState(() => _aceptaDonacionesDinero = val),
               ),
               if (_aceptaDonacionesDinero) ...[
                 const SizedBox(height: 8),
                 TextFormField(
                   controller: _metaDonacionController,
                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                   decoration: const InputDecoration(
                     labelText: 'Meta de donación en dinero (opcional)',
                     prefixIcon: Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
                   ),
                 ),
                 const SizedBox(height: 12),
               ],
               SwitchListTile(
                 title: const Text('Aceptar donaciones de artículos/insumos', style: TextStyle(fontWeight: FontWeight.w600)),
                 subtitle: const Text('Solicita artículos específicos o generales para la causa'),
                 value: _aceptaDonacionesArticulos,
                 activeThumbColor: const Color(0xFF2E7D32),
                 contentPadding: EdgeInsets.zero,
                 onChanged: (val) => setState(() => _aceptaDonacionesArticulos = val),
               ),
               if (_aceptaDonacionesArticulos) ...[
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(
                       child: TextFormField(
                         controller: _articuloSolicitadoController,
                         decoration: const InputDecoration(
                           labelText: 'Artículo solicitado (ej. Guantes, Palas)',
                           prefixIcon: Icon(Icons.inventory_2_outlined, color: Color(0xFF2E7D32)),
                         ),
                         onFieldSubmitted: (_) => _agregarArticuloSolicitado(),
                       ),
                     ),
                     const SizedBox(width: 8),
                     IconButton.filled(
                       onPressed: _agregarArticuloSolicitado,
                       icon: const Icon(Icons.add),
                       style: IconButton.styleFrom(
                         backgroundColor: const Color(0xFF2E7D32),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         padding: const EdgeInsets.all(14),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 12),
                 if (_articulosSolicitados.isNotEmpty)
                   Wrap(
                     spacing: 8,
                     runSpacing: 4,
                     children: _articulosSolicitados.map((articulo) {
                       return InputChip(
                         label: Text(articulo),
                         backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                         labelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                         deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF2E7D32)),
                         onDeleted: () {
                           setState(() {
                             _articulosSolicitados.remove(articulo);
                           });
                         },
                       );
                     }).toList(),
                   ),
               ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _publicarJornada,
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
                    : Text(
                        widget.jornadaParaEditar != null ? 'Guardar Cambios' : 'Publicar Jornada',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
             ],
           ),
         ),
       ),
      ),
    );
  }
}
