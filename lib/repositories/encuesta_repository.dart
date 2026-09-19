import 'package:supabase_flutter/supabase_flutter.dart';

class EncuestaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> obtenerEstado(String userId) async {
    try {
      final response = await _supabase
          .from('encuestas_satisfaccion_estado')
          .select()
          .eq('usuario_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> guardarEstado({
    required String userId,
    required DateTime lastShownAt,
    required int countAtShown,
    required bool respondida,
    required bool descartada,
  }) async {
    try {
      await _supabase.from('encuestas_satisfaccion_estado').upsert({
        'usuario_id': userId,
        'last_shown_at': lastShownAt.toIso8601String(),
        'last_completed_jornada_count_at_shown': countAtShown,
        'respondida': respondida,
        'descartada': descartada,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Error al guardar estado de encuesta: $e';
    }
  }

  Future<int> contarJornadasCompletadas(String userId) async {
    try {
      Set<String> jornadaIds = {};

      // 1. Como organizador
      final orgResponse = await _supabase
          .from('jornadas')
          .select('id')
          .eq('organizador_id', userId)
          .eq('estado_progreso', 'completada')
          .neq('estado', 'cancelada');

      for (var row in (orgResponse as List)) {
        jornadaIds.add(row['id'].toString());
      }

      // 2. Como voluntario inscrito
      final inscResponse = await _supabase
          .from('inscripciones')
          .select('jornada_id, jornadas!inner(id, estado_progreso, estado)')
          .eq('voluntario_id', userId);

      for (var row in (inscResponse as List)) {
        final j = row['jornadas'];
        if (j != null && j['estado_progreso'] == 'completada' && j['estado'] != 'cancelada') {
          jornadaIds.add(j['id'].toString());
        }
      }

      return jornadaIds.length;
    } catch (e) {
      return 0;
    }
  }
}
