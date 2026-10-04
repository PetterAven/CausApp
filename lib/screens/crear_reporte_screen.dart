import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/reporte_controller.dart';
import '../widgets/animated_background.dart';

class CrearReporteScreen extends ConsumerStatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  ConsumerState<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends ConsumerState<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  String _categoriaSeleccionada = 'Fuga de agua';
  final List<String> _categorias = [
    'Fuga de agua',
    'Basura',
    'Bache',
    'Alumbrado público',
    'Drenaje',
    'Otros',
  ];

  final List<File> _fotos = [];
  final ImagePicker _picker = ImagePicker();

  LatLng _ubicacionSeleccionada = const LatLng(20.0780, -98.7300); // Colonia Matilde, Pachuca, Hidalgo aprox
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionGPS();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionGPS() async {
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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _ubicacionSeleccionada = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (_) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _seleccionarFoto(ImageSource source) async {
    if (_fotos.length >= 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puedes adjuntar un máximo de 3 fotos.')),
      );
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (!mounted) return;
      if (pickedFile != null) {
        setState(() {
          _fotos.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al acceder a la cámara/galería: $e')),
      );
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              title: const Text('Tomar fotografía con la cámara'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publicarReporte() async {
    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es obligatorio adjuntar al menos una fotografía.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(reporteControllerProvider.notifier).crearReporte(
            categoria: _categoriaSeleccionada,
            descripcion: _descripcionController.text.trim(),
            fotos: _fotos,
            latitud: _ubicacionSeleccionada.latitude,
            longitud: _ubicacionSeleccionada.longitude,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reporte publicado con éxito!'),
            backgroundColor: Color(0xFF2E7D32),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Reporte'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Fotografía de la incidencia (1 a 3 fotos)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._fotos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _fotos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_fotos.length < 3)
                        InkWell(
                          onTap: _mostrarOpcionesFoto,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Color(0xFF2E7D32), size: 32),
                                SizedBox(height: 4),
                                Text('Agregar', style: TextStyle(fontSize: 12, color: Colors.black87))
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '2. Selecciona la Categoría',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categorias.map((cat) {
                    final isSelected = _categoriaSeleccionada == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _categoriaSeleccionada = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  '3. Descripción breve y Ubicación GPS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Describe el problema (ej. Fuga frente al número 12)',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa una descripción del problema.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isLoadingLocation
                              ? 'Obteniendo ubicación GPS...'
                              : 'Lat: ${_ubicacionSeleccionada.latitude.toStringAsFixed(4)}, Lon: ${_ubicacionSeleccionada.longitude.toStringAsFixed(4)} (Colonia Matilde)',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
                        onPressed: _obtenerUbicacionGPS,
                        tooltip: 'Actualizar GPS',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _publicarReporte,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Publicar Reporte'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
