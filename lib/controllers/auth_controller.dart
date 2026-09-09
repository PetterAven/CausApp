import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider que escucha los cambios de estado de autenticación en Supabase
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Provider para obtener el usuario actual de manera sencilla
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

// Controlador que agrupa las acciones de autenticación (Login, Registro, Logout)
class AuthController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Iniciar sesión con email y contraseña
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw 'Credenciales incorrectas o error al iniciar sesión.';
    }
  }

  // Registrarse con email y contraseña
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw 'El correo ya existe o la contraseña es muy débil.';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión.';
    }
  }
}

// Provider global para acceder al AuthController en las vistas
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});
