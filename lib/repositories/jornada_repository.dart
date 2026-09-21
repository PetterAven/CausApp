import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';
import '../local_db/app_database.dart';

class JornadaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  JornadaRepository(this._db);

  Jornada _jornadaFromLocal(JornadaLocal row) {
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
  }

  // Obtener todas las jornadas con estrategia Cache-then-Network
  Future<List<Jornada>> obtenerJornadas() async {
    try {
      // 1. Obtener de caché local primero para respuesta instantánea
      final localRows = await _db.obtenerJornadasLocal();
       List<Jornada> jornadasLocales = localRows
           .where((row) => row.estado != 'cancelada')
           .map((row) => _jornadaFromLocal(row))
           .toList();

      // 2. Intentar fetch de Supabase
      try {
        final response = await _supabase
            .from('jornadas')
            .select()
            .neq('estado', 'cancelada')
            .order('created_at', ascending: false);

        final jornadasRemote = (response as List)
            .map((json) => Jornada.fromJson(json as Map<String, dynamic>))
            .toList();

        // 3. Upsert en Drift
        await _db.upsertJornadas(jornadasRemote);

        return jornadasRemote;
      } catch (networkError) {
        // Si no hay conexión o falla la red, devolver datos locales cacheados
        if (jornadasLocales.isNotEmpty) {
          return jornadasLocales;
        }
        rethrow;
      }
    } catch (e) {
      throw 'Error al cargar jornadas: ${e.toString()}';
    }
  }

  // Obtener una jornada por ID
  Future<Jornada> obtenerJornadaPorId(String id) async {
    try {
      final response = await _supabase
          .from('jornadas')
          .select()
          .eq('id', id)
          .single();
      
      final jornada = Jornada.fromJson(response);
      await _db.upsertJornada(jornada);
      return jornada;
    } catch (e) {
      final localRows = await _db.obtenerJornadasLocal();
      final match = localRows.where((r) => r.id == id).firstOrNull;
      if (match != null) {
        return _jornadaFromLocal(match);
      }
      throw 'Error al obtener la jornada: ${e.toString()}';
    }
  }

  // Crear una nueva jornada
  Future<void> crearJornada(Jornada jornada) async {
    try {
      final response = await _supabase.from('jornadas').insert(jornada.toJson()).select().single();
      final nueva = Jornada.fromJson(response);
      await _db.upsertJornada(nueva);
    } catch (e) {
      throw 'Error al crear la jornada: ${e.toString()}';
    }
  }

  // Obtener jornadas creadas por un organizador específico
  Future<List<Jornada>> obtenerJornadasPorOrganizador(String organizadorId) async {
    try {
      final response = await _supabase
          .from('jornadas')
          .select()
          .eq('organizador_id', organizadorId)
          .neq('estado', 'cancelada')
          .order('created_at', ascending: false);
      
      final jornadas = (response as List)
          .map((json) => Jornada.fromJson(json as Map<String, dynamic>))
          .toList();
      await _db.upsertJornadas(jornadas);
      return jornadas;
    } catch (e) {
      final local = await _db.obtenerJornadasLocal();
      return local
          .where((r) => r.organizadorId == organizadorId && r.estado != 'cancelada')
          .map((row) => _jornadaFromLocal(row))
          .toList();
    }
  }

  // Actualizar estado de progreso de una jornada
  Future<void> actualizarEstadoProgreso(String id, String estadoProgreso) async {
    try {
      await _supabase
          .from('jornadas')
          .update({'estado_progreso': estadoProgreso})
          .eq('id', id);

      final localRows = await _db.obtenerJornadasLocal();
      final match = localRows.where((r) => r.id == id).firstOrNull;
      if (match != null) {
        final current = _jornadaFromLocal(match);
        final updated = current.copyWith(estadoProgreso: estadoProgreso);
        await _db.upsertJornada(updated);
      }
    } catch (e) {
      throw 'Error al actualizar el estado de progreso: ${e.toString()}';
    }
  }

  // Actualizar una jornada existente
  Future<void> actualizarJornada(Jornada jornada) async {
    try {
      await _supabase
          .from('jornadas')
          .update(jornada.toJson())
          .eq('id', jornada.id);

      await _db.upsertJornada(jornada);
    } catch (e) {
      throw 'Error al actualizar la jornada: ${e.toString()}';
    }
  }

  // Eliminar (borrado lógico: estado = 'cancelada') una jornada
  Future<void> eliminarJornada(String id) async {
    try {
      await _supabase
          .from('jornadas')
          .update({'estado': 'cancelada'})
          .eq('id', id);

      final localRows = await _db.obtenerJornadasLocal();
      final match = localRows.where((r) => r.id == id).firstOrNull;
      if (match != null) {
        final current = _jornadaFromLocal(match);
        final updated = current.copyWith(estado: 'cancelada');
        await _db.upsertJornada(updated);
      }
    } catch (e) {
      throw 'Error al eliminar la jornada: ${e.toString()}';
    }
  }
}
