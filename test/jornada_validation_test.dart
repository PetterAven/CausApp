import 'package:flutter_test/flutter_test.dart';
import 'package:causapp/models/jornada.dart';

void main() {
  group('Jornada Validation & Model Tests', () {
    test('Jornada with valid required fields passes validation rules', () {
      final jornada = Jornada(
        id: 'jornada-1',
        organizadorId: 'org-1',
        titulo: 'Reforestación Urbana',
        categoria: 'Ambiental',
        descripcion: 'Plantar árboles en el parque central',
        fecha: '2026-11-15',
        hora: '09:00',
        latitud: 19.4326,
        longitud: -99.1332,
        direccionReferencia: 'Parque Central',
        cupoVoluntarios: 30,
        estado: 'activa',
        estadoProgreso: 'pendiente',
        herramientasNecesarias: ['Pala', 'Guantes'],
        createdAt: DateTime.now(),
      );

      expect(jornada.id, isNotEmpty);
      expect(jornada.titulo, isNotEmpty);
      expect(jornada.latitud, isNotNull);
      expect(jornada.longitud, isNotNull);
      expect(jornada.cupoVoluntarios, greaterThan(0));
    });

    test('Jornada JSON serialization handles missing optional fields gracefully', () {
      final json = {
        'id': 'jornada-2',
        'organizador_id': 'org-2',
        'titulo': 'Taller Reciclaje',
        'categoria': 'Educativo',
        'fecha': '2026-12-01',
        'hora': '15:00',
        'latitud': 20.0,
        'longitud': -100.0,
        'created_at': '2026-09-20T00:00:00Z',
      };

      final jornada = Jornada.fromJson(json);
      expect(jornada.titulo, 'Taller Reciclaje');
      expect(jornada.descripcion, '');
      expect(jornada.direccionReferencia, '');
      expect(jornada.aceptaDonacionesDinero, false);
      expect(jornada.articulosSolicitados, isEmpty);
    });
  });
}
