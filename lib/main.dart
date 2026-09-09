import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con tus credenciales de proyecto
  // Reemplaza con tu URL y Anon Key de Supabase
  await Supabase.initialize(
    url: 'https://tu-proyecto.supabase.co',
    publishableKey: 'tu-anon-key',
  );

  runApp(
    // ProviderScope es necesario para que Riverpod funcione en toda la aplicación
    const ProviderScope(
      child: CausApp(),
    ),
  );
}

class CausApp extends ConsumerWidget {
  const CausApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de autenticación con Riverpod
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CausApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (state) {
          // Si el usuario está autenticado, mostramos el HomeShell (pantalla principal)
          // Si no, mostramos la pantalla de autenticación (Login / Registro)
          final session = state.session;
          if (session != null) {
            return const HomeShell();
          } else {
            return const AuthScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Scaffold(
          body: Center(child: Text('Error de autenticación: $e')),
        ),
      ),
    );
  }
}
