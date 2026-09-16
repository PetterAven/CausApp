import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jornada.dart';
import '../repositories/jornada_repository.dart';
import '../local_db/database_provider.dart';

final jornadaRepositoryProvider = Provider<JornadaRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return JornadaRepository(db);
});

// Stream provider reactivo basado en Drift (con caché local + sync en background)
final jornadasStreamProvider = StreamProvider<List<Jornada>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  // Disparar un fetch inicial en background
  Future.microtask(() {
    ref.read(jornadaRepositoryProvider).obtenerJornadas().catchError((_) => <Jornada>[]);
  });
  
  return db.watchJornadas().map((rows) => rows.map((row) => Jornada(
    id: row.id,
    organizadorId: row.organizadorId,
    titulo: row.titulo,
    categoria: row.categoria,
    categoriaPersonalizada: row.categoriaPersonalizada,
    descripcion: row.descripcion ?? '',
    fecha: row.fecha,
    hora: row.hora,
    latitud: row.latitud,
    longitud: row.longitud,
    direccionReferencia: row.direccionReferencia ?? '',
    cupoVoluntarios: row.cupoVoluntarios,
    estado: row.estado,
    estadoProgreso: row.estadoProgreso,
    createdAt: row.createdAt,
  )).toList());
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
        estadoProgreso: 'pendiente',
        createdAt: DateTime.now(),
      );

      await repository.crearJornada(nuevaJornada);
      return await repository.obtenerJornadas();
    });
  }

  // Actualizar estado de progreso
  Future<void> actualizarEstadoProgreso(String id, String nuevoEstado) async {
    final repository = ref.read(jornadaRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.actualizarEstadoProgreso(id, nuevoEstado);
      return await repository.obtenerJornadas();
    });
  }

  // Actualizar jornada
  Future<void> actualizarJornada(Jornada jornada) async {
    final repository = ref.read(jornadaRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.actualizarJornada(jornada);
      return await repository.obtenerJornadas();
    });
  }

  // Eliminar jornada (borrado lógico)
  Future<void> eliminarJornada(String id) async {
    final repository = ref.read(jornadaRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.eliminarJornada(id);
      return await repository.obtenerJornadas();
    });
  }
}

final jornadaControllerProvider = AsyncNotifierProvider<JornadaController, List<Jornada>>(() {
  return JornadaController();
});
