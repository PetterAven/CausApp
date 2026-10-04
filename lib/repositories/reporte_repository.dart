import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reporte.dart';
import '../models/comentario.dart';
import '../models/seguimiento.dart';

class ReporteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Reporte>> obtenerReportes() async {
    try {
      final response = await _supabase
          .from('reportes')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Reporte.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error al cargar los reportes: ${e.toString()}';
    }
  }

  Future<List<String>> subirFotos(List<File> files) async {
    List<String> urls = [];
    const bucketName = 'reportes-fotos';

    for (var file in files) {
      try {
        final userId = _supabase.auth.currentUser?.id ?? 'anon';
        final fileExt = file.path.split('.').last.toLowerCase();
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${urls.length}.$fileExt';

        await _supabase.storage.from(bucketName).upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

        final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
        urls.add(publicUrl);
      } catch (e) {
        urls.add(file.path);
      }
    }
    return urls;
  }

  Future<void> crearReporte({
    required String categoria,
    required String descripcion,
    required List<File> fotos,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw 'Debes iniciar sesión para publicar un reporte.';

      List<String> fotosUrls = await subirFotos(fotos);

      final nuevoReporte = {
        'user_id': user.id,
        'categoria': categoria,
        'descripcion': descripcion,
        'fotos': fotosUrls,
        'latitud': latitud,
        'longitud': longitud,
        'estado': 'pendiente',
        'apoyos': 0,
      };

      await _supabase.from('reportes').insert(nuevoReporte);
    } catch (e) {
      throw 'Error al crear el reporte: ${e.toString()}';
    }
  }

  // Verificar si el usuario actual ha apoyado un reporte
  Future<bool> isSupportedByUser(String reporteId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('reporte_apoyos')
          .select()
          .eq('reporte_id', reporteId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (_) {
      return false;
    }
  }

  // Alternar apoyo ("Me afecta") - Inserta o elimina de reporte_apoyos
  Future<int> toggleApoyarReporte(String reporteId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Debes iniciar sesión para apoyar.';

      final yaApoyado = await isSupportedByUser(reporteId);

      if (yaApoyado) {
        await _supabase
            .from('reporte_apoyos')
            .delete()
            .eq('reporte_id', reporteId)
            .eq('user_id', userId);
      } else {
        await _supabase
            .from('reporte_apoyos')
            .insert({'reporte_id': reporteId, 'user_id': userId});
      }

      // Obtener nuevo conteo actualizado desde la tabla reportes
      final res = await _supabase
          .from('reportes')
          .select('apoyos')
          .eq('id', reporteId)
          .single();

      return (res['apoyos'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw 'Error al actualizar apoyo: ${e.toString()}';
    }
  }

  // Verificar si el usuario actual es líder
  Future<bool> isCurrentUserLider() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final res = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      return res?['role'] == 'lider';
    } catch (_) {
      return false;
    }
  }

  // Cambiar estado (solo para líderes)
  Future<void> cambiarEstadoReporte(String reporteId, String nuevoEstado) async {
    try {
      final isLider = await isCurrentUserLider();
      if (!isLider) {
        throw 'Permiso denegado: Solo los líderes pueden cambiar el estado del reporte.';
      }

      await _supabase
          .from('reportes')
          .update({'estado': nuevoEstado})
          .eq('id', reporteId);
    } catch (e) {
      throw e.toString();
    }
  }

  // Comentarios
  Future<List<Comentario>> obtenerComentarios(String reporteId) async {
    try {
      final res = await _supabase
          .from('comentarios')
          .select()
          .eq('reporte_id', reporteId)
          .order('created_at', ascending: true);

      return (res as List).map((json) => Comentario.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> agregarComentario(String reporteId, String texto) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Debes iniciar sesión para comentar.';

      await _supabase.from('comentarios').insert({
        'reporte_id': reporteId,
        'user_id': userId,
        'texto': texto,
      });
    } catch (e) {
      throw 'Error al comentar: ${e.toString()}';
    }
  }

  // Seguimientos (historial)
  Future<List<Seguimiento>> obtenerSeguimientos(String reporteId) async {
    try {
      final res = await _supabase
          .from('seguimientos')
          .select()
          .eq('reporte_id', reporteId)
          .order('created_at', ascending: false);

      return (res as List).map((json) => Seguimiento.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
