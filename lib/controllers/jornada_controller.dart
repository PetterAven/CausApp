import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jornada.dart';
import '../repositories/jornada_repository.dart';

final jornadaRepositoryProvider = Provider<JornadaRepository>((ref) {
  return JornadaRepository();
});

class JornadaController extends AsyncNotifier<List<Jornada>> {
  @override
  Future<List<Jornada>> build() async {
    return _cargarJornadas();
  }

  Future<List<Jornada>> _cargarJornadas() async {
    final repository = ref.read(jornadaRepositoryProvider);
    return await repository.obtenerJornadas();
  }

  // Recargar la lista de jornadas
  Future<void> recargar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _cargarJornadas());
  }

  // Crear una nueva jornada
  Future<void> crearJornada({
    required String organizadorId,
    required String titulo,
    required String categoria,
    String? categoriaPersonalizada,
    required String descripcion,
    required String fecha,
    required String hora,
    required double latitud,
    required double longitud,
    required String direccionReferencia,
    int? cupoVoluntarios,
  }) async {
    final repository = ref.read(jornadaRepositoryProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final nuevaJornada = Jornada(
        id: '', // Supabase generará el UUID
        organizadorId: organizadorId,
        titulo: titulo,
        categoria: categoria,
        categoriaPersonalizada: categoriaPersonalizada,
        descripcion: descripcion,
        fecha: fecha,
        hora: hora,
        latitud: latitud,
        longitud: longitud,
        direccionReferencia: direccionReferencia,
        cupoVoluntarios: cupoVoluntarios,
        estado: 'activa',
        createdAt: DateTime.now(),
      );

      await repository.crearJornada(nuevaJornada);
      return await repository.obtenerJornadas();
    });
  }
}

final jornadaControllerProvider = AsyncNotifierProvider<JornadaController, List<Jornada>>(() {
  return JornadaController();
});
