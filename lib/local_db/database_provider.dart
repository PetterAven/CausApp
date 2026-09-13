import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Initial check
  final results = await connectivity.checkConnectivity();
  final isConnected = results.any((r) => r != ConnectivityResult.none);
  yield isConnected;

  // Listen to connectivity changes and trigger sync if online
  yield* connectivity.onConnectivityChanged.map((results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online) {
      // Trigger background sync when connection is restored
      ref.read(syncServiceProvider).sincronizarPendientes();
    }
    return online;
  });
});

class SyncService {
  final Ref ref;
  SyncService(this.ref);

  Future<void> sincronizarPendientes() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final pendientes = await db.obtenerPendientesSync();
      
      if (pendientes.isEmpty) return;

      final supabase = Supabase.instance.client;

      for (var p in pendientes) {
        try {
          if (p.isDeleted) {
            await supabase
                .from('inscripciones')
                .delete()
                .eq('jornada_id', p.jornadaId)
                .eq('voluntario_id', p.voluntarioId);
            
            await db.eliminarInscripcionDefinitiva(p.jornadaId, p.voluntarioId);
          } else {
            final response = await supabase.from('inscripciones').insert({
              'jornada_id': p.jornadaId,
              'voluntario_id': p.voluntarioId,
            }).select('id').single();

            final serverId = response['id'].toString();
            await db.marcarSincronizado(p.jornadaId, p.voluntarioId, serverId: serverId);
          }
        } catch (e) {
          if (e.toString().contains('duplicate key') || e.toString().contains('violates unique constraint')) {
            await db.marcarSincronizado(p.jornadaId, p.voluntarioId);
          }
        }
      }
    } catch (_) {
      // Ignorar errores generales de sincronización
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

final syncStatusProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchPendientesCount();
});
