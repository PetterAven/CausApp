import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

// ConsumerStatefulWidget nos permite mantener estado local (inputs, loading, modo login/registro)
// y a la vez escuchar/leer providers de Riverpod usando `ref`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controladores para capturar el texto de los inputs de email y contraseña
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Bandera para saber si estamos en modo Login (true) o Registro (false)
  bool _isLoginMode = true;
  
  // Bandera para mostrar el indicador de carga (loading)
  bool _isLoading = false;

  @override
  void dispose() {
    // Es importante liberar los controladores cuando el widget se destruye
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para manejar el envío del formulario (Iniciar sesión o Registrarse)
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider);

      if (_isLoginMode) {
        // Lógica de inicio de sesión
        await authController.signIn(email: email, password: password);
      } else {
        // Lógica de registro
        await authController.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cuenta creada con éxito! Ya puedes iniciar sesión.')),
          );
          setState(() {
            _isLoginMode = true; // Cambiar a vista de login tras registrarse
          });
        }
      }
    } catch (e) {
      // Manejo de errores mostrando un SnackBar como se solicitó
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Iniciar Sesión - CausApp' : 'Crear Cuenta - CausApp'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono decorativo de la app
                const Icon(
                  Icons.volunteer_activism,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                
                // Campo de texto para el Correo electrónico
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de texto para la Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Ocultar caracteres de la contraseña
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón principal (Iniciar sesión o Registrarse)
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLoginMode ? 'Iniciar sesión' : 'Crear cuenta',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Botón/link para alternar entre iniciar sesión y crear cuenta
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? '¿No tienes cuenta? Crear cuenta'
                        : '¿Ya tienes cuenta? Iniciar sesión',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
