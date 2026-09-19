import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const int terminosVersionActual = 1;

class TerminosScreen extends ConsumerStatefulWidget {
  const TerminosScreen({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  ConsumerState<TerminosScreen> createState() => _TerminosScreenState();
}

class _TerminosScreenState extends ConsumerState<TerminosScreen> {
  bool _accepted = false;
  bool _isLoading = false;

  Future<void> _guardarAceptacion() async {
    if (!_accepted) return;
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'terminos_aceptados_version': terminosVersionActual,
          'terminos_aceptados_at': DateTime.now().toIso8601String(),
        });
      }
      widget.onAccepted();
    } catch (e) {
      if (mounted) {
        // Fallback si la tabla profiles aún no existe o hay error de red, permitimos continuar localmente y reintentar
        widget.onAccepted();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Términos y Condiciones', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Por favor, lee y acepta los términos para continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '1. Uso de la Aplicación',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'CausApp es una plataforma comunitaria diseñada para conectar voluntarios con jornadas de apoyo y causas sociales. Al utilizar esta aplicación, te comprometes a hacer un uso responsable, respetuoso y conforme a las leyes aplicables.',
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '2. Responsabilidad en Jornadas Comunitarias',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Los organizadores y participantes de las jornadas actúan de manera voluntaria. CausApp no asume responsabilidad civil o penal por incidentes, accidentes o daños ocurridos durante el desarrollo de las actividades presenciales organizadas a través de la plataforma.',
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '3. Tratamiento de Datos Personales',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tus datos personales, correo electrónico y perfil de usuario se utilizan exclusivamente para la gestión de inscripciones, coordinación de jornadas y mejora de la experiencia en la aplicación, garantizando la privacidad y seguridad de tu información.',
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '4. Modificación de los Términos',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Nos reservamos el derecho de actualizar estos términos en cualquier momento. Al continuar utilizando CausApp tras la actualización, aceptas expresamente la nueva versión de los términos y condiciones.',
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (val) {
                        setState(() => _accepted = val ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'He leído y acepto los Términos y Condiciones',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_accepted && !_isLoading) ? _guardarAceptacion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Continuar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
