import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recurso.dart';
import '../models/mensaje_recurso.dart';

class RecursoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Recurso>> obtenerRecursos() async {
    try {
      final response = await _supabase
          .from('recursos_prestamo')
          .select()
          .order('fecha_publicacion', ascending: false);

      return (response as List)
          .map((json) => Recurso.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener recursos: ${e.toString()}';
    }
  }

  Future<List<Recurso>> obtenerRecursosPorJornada(String jornadaId) async {
    try {
      final response = await _supabase
          .from('recursos_prestamo')
          .select()
          .eq('jornada_id', jornadaId)
          .order('fecha_publicacion', ascending: false);

      return (response as List)
          .map((json) => Recurso.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener recursos de la jornada: ${e.toString()}';
    }
  }

  Future<void> crearRecurso(Recurso recurso) async {
    try {
      await _supabase.from('recursos_prestamo').insert(recurso.toJson());
    } catch (e) {
      throw 'Error al publicar recurso: ${e.toString()}';
    }
  }

  Future<void> actualizarEstadoRecurso(String id, String estado) async {
    try {
      await _supabase
          .from('recursos_prestamo')
          .update({'estado': estado})
          .eq('id', id);
    } catch (e) {
      throw 'Error al actualizar estado del recurso: ${e.toString()}';
    }
  }

  Future<List<MensajeRecurso>> obtenerMensajes(String recursoId) async {
    try {
      final response = await _supabase
          .from('mensajes_recurso')
          .select()
          .eq('recurso_id', recursoId)
          .order('fecha', ascending: true);

      return (response as List)
          .map((json) => MensajeRecurso.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al obtener mensajes: ${e.toString()}';
    }
  }

  Future<void> enviarMensaje(MensajeRecurso mensaje) async {
    try {
      await _supabase.from('mensajes_recurso').insert(mensaje.toJson());
    } catch (e) {
      throw 'Error al enviar mensaje: ${e.toString()}';
    }
  }

  Stream<List<MensajeRecurso>> streamMensajes(String recursoId) {
    return _supabase
        .from('mensajes_recurso')
        .stream(primaryKey: ['id'])
        .eq('recurso_id', recursoId)
        .order('fecha', ascending: true)
        .map((rows) => rows.map((json) => MensajeRecurso.fromJson(json)).toList());
  }
}
