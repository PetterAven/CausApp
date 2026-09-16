import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurso.dart';
import '../models/mensaje_recurso.dart';
import '../repositories/recurso_repository.dart';

final recursoRepositoryProvider = Provider<RecursoRepository>((ref) {
  return RecursoRepository();
});

final recursosProvider = FutureProvider<List<Recurso>>((ref) async {
  final repo = ref.read(recursoRepositoryProvider);
  return await repo.obtenerRecursos();
});

final recursosPorJornadaProvider = FutureProvider.family<List<Recurso>, String>((ref, jornadaId) async {
  final repo = ref.read(recursoRepositoryProvider);
  return await repo.obtenerRecursosPorJornada(jornadaId);
});

final mensajesRecursoStreamProvider = StreamProvider.family<List<MensajeRecurso>, String>((ref, recursoId) {
  final repo = ref.read(recursoRepositoryProvider);
  return repo.streamMensajes(recursoId);
});

class RecursoController extends AsyncNotifier<List<Recurso>> {
  @override
  Future<List<Recurso>> build() async {
    final repo = ref.read(recursoRepositoryProvider);
    return await repo.obtenerRecursos();
  }

  Future<void> recargar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recursoRepositoryProvider);
      return await repo.obtenerRecursos();
    });
  }

  Future<void> publicarRecurso({
    String? jornadaId,
    required String usuarioId,
    required String nombreArticulo,
    required int cantidad,
    required String descripcion,
    required String estado,
  }) async {
    final repo = ref.read(recursoRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final recurso = Recurso(
        id: '',
        jornadaId: jornadaId,
        usuarioId: usuarioId,
        nombreArticulo: nombreArticulo,
        cantidad: cantidad,
        descripcion: descripcion,
        estado: estado,
        fechaPublicacion: DateTime.now(),
      );
      await repo.crearRecurso(recurso);
      return await repo.obtenerRecursos();
    });
  }

  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    final repo = ref.read(recursoRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.actualizarEstadoRecurso(id, nuevoEstado);
      return await repo.obtenerRecursos();
    });
  }

  Future<void> enviarMensaje({
    required String recursoId,
    required String usuarioId,
    required String mensaje,
  }) async {
    final repo = ref.read(recursoRepositoryProvider);
    final nuevoMensaje = MensajeRecurso(
      id: '',
      recursoId: recursoId,
      usuarioId: usuarioId,
      mensaje: mensaje,
      fecha: DateTime.now(),
    );
    await repo.enviarMensaje(nuevoMensaje);
  }
}

final recursoControllerProvider = AsyncNotifierProvider<RecursoController, List<Recurso>>(() {
  return RecursoController();
});
