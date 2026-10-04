import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reporte.dart';
import '../repositories/reporte_repository.dart';

final reporteRepositoryProvider = Provider<ReporteRepository>((ref) {
  return ReporteRepository();
});

class ReporteController extends AsyncNotifier<List<Reporte>> {
  @override
  Future<List<Reporte>> build() async {
    final repo = ref.read(reporteRepositoryProvider);
    return await repo.obtenerReportes();
  }

  Future<void> recargar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(reporteRepositoryProvider);
      return await repo.obtenerReportes();
    });
  }

  Future<void> crearReporte({
    required String categoria,
    required String descripcion,
    required List<File> fotos,
    required double latitud,
    required double longitud,
  }) async {
    final repo = ref.read(reporteRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.crearReporte(
        categoria: categoria,
        descripcion: descripcion,
        fotos: fotos,
        latitud: latitud,
        longitud: longitud,
      );
      return await repo.obtenerReportes();
    });
  }

  Future<int> toggleApoyarReporte(String reporteId) async {
    final repo = ref.read(reporteRepositoryProvider);
    try {
      final nuevoConteo = await repo.toggleApoyarReporte(reporteId);
      await recargar();
      return nuevoConteo;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cambiarEstado(String reporteId, String nuevoEstado) async {
    final repo = ref.read(reporteRepositoryProvider);
    await repo.cambiarEstadoReporte(reporteId, nuevoEstado);
    await recargar();
  }
}

final reporteControllerProvider = AsyncNotifierProvider<ReporteController, List<Reporte>>(() {
  return ReporteController();
});
