import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/inscripcion_repository.dart';
import '../models/jornada.dart';
import 'jornada_controller.dart';
import '../local_db/database_provider.dart';
import '../services/notification_service.dart';

final inscripcionRepositoryProvider = Provider<InscripcionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return InscripcionRepository(db);
});

class InscripcionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No estado inicial complejo requerido en build general
  }

  // Inscribirse en una jornada (soporte offline)
  Future<void> inscribirse(String jornadaId, String voluntarioId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(inscripcionRepositoryProvider);
      await repo.inscribirse(jornadaId, voluntarioId);
      try {
        final jornadaRepo = ref.read(jornadaRepositoryProvider);
        final jornada = await jornadaRepo.obtenerJornadaPorId(jornadaId);
        await NotificationService().programarRecordatorioJornada(jornada);
      } catch (_) {}
      // Forzar sincronización si hay conexión
      ref.read(syncServiceProvider).sincronizarPendientes();
    });
  }

  // Cancelar inscripción (soporte offline)
  Future<void> cancelarInscripcion(String jornadaId, String voluntarioId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(inscripcionRepositoryProvider);
      await repo.cancelarInscripcion(jornadaId, voluntarioId);
      await NotificationService().cancelarRecordatorio(jornadaId);
      ref.read(syncServiceProvider).sincronizarPendientes();
    });
  }
}

final inscripcionControllerProvider = AsyncNotifierProvider<InscripcionController, void>(() {
  return InscripcionController();
});

// Provider para contar inscritos en tiempo de ejecución / lectura
final inscritosCountProvider = FutureProvider.family<int, String>((ref, jornadaId) async {
  final repo = ref.read(inscripcionRepositoryProvider);
  return await repo.contarInscritos(jornadaId);
});

// Provider para verificar si el usuario está inscrito
final estaInscritoProvider = FutureProvider.family<bool, ({String jornadaId, String voluntarioId})>((ref, params) async {
  final repo = ref.read(inscripcionRepositoryProvider);
  return await repo.estaInscrito(params.jornadaId, params.voluntarioId);
});

// Provider para obtener jornadas en las que participa el usuario
final jornadasInscritasProvider = FutureProvider.family<List<Jornada>, String>((ref, voluntarioId) async {
  final repo = ref.read(inscripcionRepositoryProvider);
  return await repo.obtenerJornadasInscritas(voluntarioId);
});

// Provider para obtener jornadas organizadas por el usuario
final jornadasOrganizadasProvider = FutureProvider.family<List<Jornada>, String>((ref, organizadorId) async {
  final repo = ref.read(jornadaRepositoryProvider);
  return await repo.obtenerJornadasPorOrganizador(organizadorId);
});
