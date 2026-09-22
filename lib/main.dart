import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';
import 'controllers/jornada_controller.dart';
import 'controllers/inscripcion_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';
import 'screens/terminos_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  debugPrint('Startup start: ${DateTime.now()}');
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hisifcteaatneevrjvov.supabase.co',
    publishableKey: 'sb_publishable_-ycdBKUc7LuIxzyhVdIE9g_MvUbIblZ',
  );

  await NotificationService().init();
  debugPrint('NotificationService init done: ${DateTime.now()}');

  runApp(
    const ProviderScope(
      child: CausApp(),
    ),
  );
  debugPrint('runApp called: ${DateTime.now()}');
}

class TerminosCheckWrapper extends ConsumerStatefulWidget {
  const TerminosCheckWrapper({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<TerminosCheckWrapper> createState() => _TerminosCheckWrapperState();
}

class _TerminosCheckWrapperState extends ConsumerState<TerminosCheckWrapper> {
  bool _checking = true;
  bool _needsTerms = false;

  @override
  void initState() {
    super.initState();
    _checkTermsAndSyncNotifications();
  }

  Future<void> _checkTermsAndSyncNotifications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _checking = false;
          _needsTerms = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select('terminos_aceptados_version')
          .eq('id', user.id)
          .maybeSingle();

      final version = response?['terminos_aceptados_version'] as int?;
      if (version == null || version < terminosVersionActual) {
        setState(() {
          _checking = false;
          _needsTerms = true;
        });
        return;
      }

      setState(() {
        _checking = false;
        _needsTerms = false;
      });

      Future.microtask(() {
        _sincronizarNotificacionesPendientes(user.id);
      });
    } catch (_) {
      setState(() {
        _checking = false;
        _needsTerms = false;
      });
    }
  }

  Future<void> _sincronizarNotificacionesPendientes(String userId) async {
    try {
      final notificationService = NotificationService();
      final jornadaRepo = ref.read(jornadaRepositoryProvider);
      final inscripcionRepo = ref.read(inscripcionRepositoryProvider);

      final organizadas = await jornadaRepo.obtenerJornadasPorOrganizador(userId);
      final inscritas = await inscripcionRepo.obtenerJornadasInscritas(userId);

      final todas = [...organizadas, ...inscritas];
      final now = DateTime.now();

      for (var j in todas) {
        if (j.estado != 'cancelada') {
          final parts = j.fecha.split('-');
          if (parts.length == 3) {
            final jDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            if (jDate.isAfter(now) || (jDate.year == now.year && jDate.month == now.month && jDate.day == now.day)) {
              await notificationService.programarRecordatorioJornada(j);
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    if (_needsTerms) {
      return TerminosScreen(
        onAccepted: () {
          setState(() => _needsTerms = false);
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            _sincronizarNotificacionesPendientes(user.id);
          }
        },
      );
    }

    return widget.child;
  }
}

class CausAppRoot extends ConsumerWidget {
  const CausAppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        final session = state.session;
        if (session != null) {
          return const TerminosCheckWrapper(child: HomeShell());
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar la autenticación: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class CausApp extends StatelessWidget {
  const CausApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CausApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF43A047),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shadowColor: Color(0x14000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const CausAppRoot(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const CausAppRoot(),
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const CausAppRoot(),
        );
      },
    );
  }
}
