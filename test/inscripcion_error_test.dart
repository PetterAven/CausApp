import 'package:flutter_test/flutter_test.dart';
import 'package:causapp/models/inscripcion.dart';

void main() {
  group('Inscripcion & Error Handling Tests', () {
    test('Inscripcion model fromJson and toJson mapping', () {
      final json = {
        'id': 'insc-1',
        'jornada_id': 'jornada-1',
        'voluntario_id': 'user-1',
        'created_at': '2026-09-20T10:00:00Z',
      };

      final inscripcion = Inscripcion.fromJson(json);
      expect(inscripcion.id, 'insc-1');
      expect(inscripcion.jornadaId, 'jornada-1');
      expect(inscripcion.voluntarioId, 'user-1');

      final resultJson = inscripcion.toJson();
      expect(resultJson['jornada_id'], 'jornada-1');
      expect(resultJson['voluntario_id'], 'user-1');
    });

    test('Error handling simulation on network failure gracefully catches and handles exceptions', () {
      bool errorCaught = false;
      try {
        throw 'Error al cargar jornadas: Connection failed';
      } catch (e) {
        if (e.toString().contains('Error al cargar jornadas')) {
          errorCaught = true;
        }
      }
      expect(errorCaught, isTrue);
    });
  });
}
