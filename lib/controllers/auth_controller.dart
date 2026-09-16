import 'dart:io';
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

// Controlador que agrupa las acciones de autenticación (Login, Registro, Logout, Perfil)
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

  // Actualizar perfil (nombre de usuario, correo y/o avatar)
  Future<void> updateProfile({String? username, String? email, String? avatarUrl}) async {
    try {
      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          data: data.isNotEmpty ? data : null,
        ),
      );
    } catch (e) {
      throw 'Error al actualizar el perfil: $e';
    }
  }

  // Subir avatar a Supabase Storage o devolver ruta local
  Future<String?> uploadAvatar(String filePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final file = File(filePath);
      final fileExt = filePath.split('.').last.toLowerCase();
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      const bucketName = 'avatars';

      try {
        await _supabase.storage.from(bucketName).upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
        final imageUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
        return imageUrl;
      } catch (_) {
        // Fallback si el bucket no existe en Supabase Storage
        return filePath;
      }
    } catch (e) {
      return null;
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

  // Enviar correo de recuperación de contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Error al enviar correo de recuperación.';
    }
  }

  // Establecer nueva contraseña
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw 'Error al actualizar la contraseña.';
    }
  }

  // Reenviar correo de confirmación/verificación
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw 'Error al reenviar correo de confirmación.';
    }
  }
}

// Provider global para acceder al AuthController en las vistas
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});
