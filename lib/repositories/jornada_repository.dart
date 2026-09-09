import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/jornada.dart';

class JornadaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todas las jornadas activas
  Future<List<Jornada>> obtenerJornadas() async {
    try {
      final response = await _supabase
          .from('jornadas')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Jornada.fromJson(json as Map<String, dynamic>))
          .toList();
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
      
      return Jornada.fromJson(response);
    } catch (e) {
      throw 'Error al obtener la jornada: ${e.toString()}';
    }
  }

  // Crear una nueva jornada
  Future<void> crearJornada(Jornada jornada) async {
    try {
      await _supabase.from('jornadas').insert(jornada.toJson());
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
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Jornada.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al cargar tus jornadas organizadas: ${e.toString()}';
    }
  }
}
