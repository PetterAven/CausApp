import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jornada.dart';
import '../repositories/jornada_repository.dart';
import '../local_db/database_provider.dart';
import '../services/notification_service.dart';

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
  
  return db.watchJornadas().map((rows) => rows.map((row) {
    List<String> articulos = [];
    try {
      if (row.articulosSolicitados != null && row.articulosSolicitados!.isNotEmpty) {
        final decoded = jsonDecode(row.articulosSolicitados!);
        if (decoded is List) {
          articulos = decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    return Jornada(
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
      aceptaDonacionesDinero: row.aceptaDonacionesDinero,
      aceptaDonacionesArticulos: row.aceptaDonacionesArticulos,
      metaDonacionDinero: row.metaDonacionDinero,
      articulosSolicitados: articulos,
      herramientasNecesarias: const [],
      createdAt: row.createdAt,
    );
  }).toList());
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
    List<String> herramientasNecesarias = const [],
    bool aceptaDonacionesDinero = false,
    bool aceptaDonacionesArticulos = false,
    double? metaDonacionDinero,
    List<String> articulosSolicitados = const [],
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
        herramientasNecesarias: herramientasNecesarias,
        aceptaDonacionesDinero: aceptaDonacionesDinero,
        aceptaDonacionesArticulos: aceptaDonacionesArticulos,
        metaDonacionDinero: metaDonacionDinero,
        articulosSolicitados: articulosSolicitados,
        createdAt: DateTime.now(),
      );

      await repository.crearJornada(nuevaJornada);
      Future.microtask(() async {
        try {
          final list = await repository.obtenerJornadas();
          final creada = list.where((j) => j.organizadorId == organizadorId && j.titulo == titulo).firstOrNull;
          if (creada != null) {
            await NotificationService().programarRecordatorioJornada(creada);
          }
        } catch (e) {
          debugPrint('Error al programar notificación de nueva jornada: $e');
        }
      });
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
      Future.microtask(() async {
        try {
          await NotificationService().cancelarRecordatorio(jornada.id);
          await NotificationService().programarRecordatorioJornada(jornada);
        } catch (e) {
          debugPrint('Error al actualizar notificación de jornada: $e');
        }
      });
      return await repository.obtenerJornadas();
    });
  }

  // Eliminar jornada (borrado lógico)
  Future<void> eliminarJornada(String id) async {
    final repository = ref.read(jornadaRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.eliminarJornada(id);
      Future.microtask(() async {
        try {
          await NotificationService().cancelarRecordatorio(id);
        } catch (e) {
          debugPrint('Error al cancelar notificación de jornada eliminada: $e');
        }
      });
      return await repository.obtenerJornadas();
    });
  }
}

final jornadaControllerProvider = AsyncNotifierProvider<JornadaController, List<Jornada>>(() {
  return JornadaController();
});
