import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider para la sesión actual de Supabase Auth
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Provider para el usuario actual o null
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

class AuthController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw 'Error al iniciar sesión: ${e.toString()}';
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      throw 'Error al registrarse: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: ${e.toString()}';
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});
