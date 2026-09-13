import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';
import '../local_db/app_database.dart';

class InscripcionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  InscripcionRepository(this._db);

  // Inscribir al usuario actual en una jornada (soporte offline)
  Future<void> inscribirse(String jornadaId, String voluntarioId) async {
    try {
      final response = await _supabase.from('inscripciones').insert({
        'jornada_id': jornadaId,
        'voluntario_id': voluntarioId,
      }).select('id').single();

      final serverId = response['id'].toString();

      await _db.guardarInscripcionLocal(
        id: serverId,
        jornadaId: jornadaId,
        voluntarioId: voluntarioId,
        createdAt: DateTime.now(),
        pendingSync: false,
      );
    } catch (e) {
      // Guardar en cola local para sincronización posterior
      await _db.guardarInscripcionLocal(
        jornadaId: jornadaId,
        voluntarioId: voluntarioId,
        createdAt: DateTime.now(),
        pendingSync: true,
      );
    }
  }

  // Cancelar inscripción (soporte offline)
  Future<void> cancelarInscripcion(String jornadaId, String voluntarioId) async {
    try {
      await _supabase
          .from('inscripciones')
          .delete()
          .eq('jornada_id', jornadaId)
          .eq('voluntario_id', voluntarioId);

      await _db.eliminarInscripcionDefinitiva(jornadaId, voluntarioId);
    } catch (e) {
      await _db.eliminarInscripcionLocal(jornadaId, voluntarioId);
    }
  }

  // Contar número de inscritos en una jornada
  Future<int> contarInscritos(String jornadaId) async {
    try {
      final response = await _supabase
          .from('inscripciones')
          .select('id')
          .eq('jornada_id', jornadaId);
      
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Verificar si el usuario está inscrito en una jornada
  Future<bool> estaInscrito(String jornadaId, String voluntarioId) async {
    try {
      final response = await _supabase
          .from('inscripciones')
          .select('id')
          .eq('jornada_id', jornadaId)
          .eq('voluntario_id', voluntarioId);
      
      if ((response as List).isNotEmpty) {
        await _db.guardarInscripcionLocal(
          id: response[0]['id'].toString(),
          jornadaId: jornadaId,
          voluntarioId: voluntarioId,
          createdAt: DateTime.now(),
          pendingSync: false,
        );
        return true;
      }

      final local = await _db.obtenerInscripcionesLocal(voluntarioId);
      return local.any((i) => i.jornadaId == jornadaId && !i.isDeleted);
    } catch (e) {
      final local = await _db.obtenerInscripcionesLocal(voluntarioId);
      return local.any((i) => i.jornadaId == jornadaId && !i.isDeleted);
    }
  }

  // Obtener jornadas en las que el usuario está inscrito
  Future<List<Jornada>> obtenerJornadasInscritas(String voluntarioId) async {
    try {
      final response = await _supabase
          .from('inscripciones')
          .select('jornadas(*)')
          .eq('voluntario_id', voluntarioId);

      final List<dynamic> data = response as List;
      List<Jornada> jornadas = [];
      for (var item in data) {
        if (item['jornadas'] != null) {
          final j = Jornada.fromJson(item['jornadas'] as Map<String, dynamic>);
          jornadas.add(j);
          await _db.upsertJornada(j);
        }
      }
      return jornadas;
    } catch (e) {
      final localInscripciones = await _db.obtenerInscripcionesLocal(voluntarioId);
      final jornadaIds = localInscripciones.where((i) => !i.isDeleted).map((i) => i.jornadaId).toList();
      
      final allLocalJornadas = await _db.obtenerJornadasLocal();
      List<Jornada> jornadas = [];
      for (var row in allLocalJornadas) {
        if (jornadaIds.contains(row.id)) {
          jornadas.add(Jornada(
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
            createdAt: row.createdAt,
          ));
        }
      }
      return jornadas;
    }
  }
}
