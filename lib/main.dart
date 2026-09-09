import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  // Aseguramos que los bindings de Flutter estén inicializados antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configuración de Supabase.initialize() con tu URL y Publishable Key reales
  await Supabase.initialize(
    url: 'https://hisifcteaatneevrjvov.supabase.co',
    publishableKey: 'sb_publishable_-ycdBKUc7LuIxzyhVdIE9g_MvUbIblZ',
  );

  runApp(
    // ProviderScope es obligatorio en la raíz para que Riverpod funcione
    const ProviderScope(
      child: CausApp(),
    ),
  );
}

class CausApp extends ConsumerWidget {
  const CausApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Escuchamos authStateProvider para determinar si hay sesión activa
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
          // Si hay sesión activa (state.session != null), mostramos HomePlaceholderScreen
          // Si no hay sesión, mostramos LoginScreen
          final session = state.session;
          if (session != null) {
            return const HomeShell();
          } else {
            return const LoginScreen();
          }
        },
        // Indicador de carga mientras se verifica el estado inicial de la sesión
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        ),
        // Manejo de error en caso de fallo al obtener el estado de autenticación
        error: (error, stackTrace) => Scaffold(
          body: Center(
            child: Text('Error al cargar la autenticación: $error'),
          ),
        ),
      ),
    );
  }
}
