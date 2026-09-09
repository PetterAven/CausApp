import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/auth_controller.dart';
import '../controllers/jornada_controller.dart';

class CrearJornadaScreen extends ConsumerStatefulWidget {
  const CrearJornadaScreen({Key? key}) : super(key: key);

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

  String _categoriaSeleccionada = 'Limpieza';
  final List<String> _categorias = ['Baches', 'Limpieza', 'Reforestación', 'Pintura', 'Otro'];

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  // Ubicación inicial por defecto (ej. Centro de la CDMX o similar)
  LatLng _ubicacionSeleccionada = const LatLng(19.432608, -99.133209);
  GoogleMapController? _mapController;
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _categoriaPersonalizadaController.dispose();
    _direccionReferenciaController.dispose();
    _cupoController.dispose();
    super.dispose();
  }

  // Obtener ubicación actual del organizador para centrar el mapa
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

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_ubicacionSeleccionada, 15),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  // Selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  // Selector de hora
  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  Future<void> _publicarJornada() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora de la jornada.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
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
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Jornada publicada exitosamente!')),
        );
        // Limpiar formulario
        _tituloController.clear();
        _descripcionController.clear();
        _categoriaPersonalizadaController.clear();
        _direccionReferenciaController.clear();
        _cupoController.clear();
        setState(() {
          _fechaSeleccionada = null;
          _horaSeleccionada = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: ${e.toString()}'), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Jornada Comunitaria'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la jornada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown de Categoría
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
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

              // Si categoría es "Otro", mostrar campo personalizado
              if (_categoriaSeleccionada == 'Otro') ...[
                TextFormField(
                  controller: _categoriaPersonalizadaController,
                  decoration: const InputDecoration(
                    labelText: 'Especifica la categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _categoriaSeleccionada == 'Otro' && (value == null || value.isEmpty)
                      ? 'Escribe la categoría'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              // Selector de Fecha y Hora
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarFecha(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_fechaSeleccionada == null
                          ? 'Elegir Fecha'
                          : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarHora(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(_horaSeleccionada == null
                          ? 'Elegir Hora'
                          : _horaSeleccionada!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mapa para seleccionar ubicación
              const Text(
                'Selecciona la ubicación exacta (mueve el mapa / pin):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _ubicacionSeleccionada,
                            zoom: 15,
                          ),
                          onMapCreated: (controller) => _mapController = controller,
                          onCameraMove: (position) {
                            _ubicacionSeleccionada = position.target;
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          // Marcador fijo en el centro que indica la ubicación seleccionada
                          markers: {
                            Marker(
                              markerId: const MarkerId('ubicacion_jornada'),
                              position: _ubicacionSeleccionada,
                              draggable: true,
                              onDragEnd: (newPosition) {
                                setState(() => _ubicacionSeleccionada = newPosition);
                              },
                            ),
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nota: El marcador en el centro indica el punto exacto. Puedes mover el mapa.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Dirección de referencia
              TextFormField(
                controller: _direccionReferenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de dirección (ej. Frente a la tienda X)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Cupo de voluntarios (opcional)
              TextFormField(
                controller: _cupoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cupo máximo de voluntarios (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
              ),
              const SizedBox(height: 32),

              // Botón Publicar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _publicarJornada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Publicar Jornada',
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
