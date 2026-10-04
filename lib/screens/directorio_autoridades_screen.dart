import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';

class DirectorioAutoridadesScreen extends StatelessWidget {
  const DirectorioAutoridadesScreen({super.key});

  final List<Map<String, String>> _autoridades = const [
    {
      'nombre': 'Atención Ciudadana - Municipio de Pachuca',
      'cargo': 'Gestión de servicios urbanos y bacheo',
      'telefono': '771 717 1500 (Ejemplo)',
      'correo': 'atencion@pachuca.gob.mx (Ejemplo)',
      'horario': 'Lunes a Viernes, 8:30 - 16:30 hrs',
    },
    {
      'nombre': 'CAASIM (Comisión de Agua y Alcantarillado)',
      'cargo': 'Reporte de fugas de agua y drenaje',
      'telefono': '771 717 6800 (Ejemplo)',
      'correo': 'reportes@caasim.gob.mx (Ejemplo)',
      'horario': '24 horas, 365 días',
    },
    {
      'nombre': 'Secretaría de Obras Públicas Municipales',
      'cargo': 'Alumbrado público y pavimentación',
      'telefono': '771 717 1520 (Ejemplo)',
      'correo': 'obras@pachuca.gob.mx (Ejemplo)',
      'horario': 'Lunes a Viernes, 9:00 - 15:00 hrs',
    },
    {
      'nombre': 'Comité Vecinal - Colonia Matilde',
      'cargo': 'Coordinación comunitaria y seguridad vecinal',
      'telefono': '771 000 0000 (Ejemplo)',
      'correo': 'vecinos.matilde@email.com (Ejemplo)',
      'horario': 'Fines de semana y emergencias',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Autoridades'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _autoridades.length,
          itemBuilder: (context, index) {
            final auth = _autoridades[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Color(0xFF2E7D32), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            auth['nombre']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth['cargo']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(auth['telefono']!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(auth['correo']!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(auth['horario']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
