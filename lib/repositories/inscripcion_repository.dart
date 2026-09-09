import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';

class InscripcionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Inscribir al usuario actual en una jornada
  Future<void> inscribirse(String jornadaId, String voluntarioId) async {
    try {
      await _supabase.from('inscripciones').insert({
        'jornada_id': jornadaId,
        'voluntario_id': voluntarioId,
      });
    } catch (e) {
      throw 'Error al inscribirse en la jornada: ${e.toString()}';
    }
  }

  // Cancelar inscripción
  Future<void> cancelarInscripcion(String jornadaId, String voluntarioId) async {
    try {
      await _supabase
          .from('inscripciones')
          .delete()
          .eq('jornada_id', jornadaId)
          .eq('voluntario_id', voluntarioId);
    } catch (e) {
      throw 'Error al cancelar la inscripción: ${e.toString()}';
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
      
      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
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
          jornadas.add(Jornada.fromJson(item['jornadas'] as Map<String, dynamic>));
        }
      }
      return jornadas;
    } catch (e) {
      throw 'Error al cargar jornadas inscritas: ${e.toString()}';
    }
  }
}
