import 'package:flutter_test/flutter_test.dart';
import 'package:causapp/models/jornada.dart';

void main() {
  group('Jornada Model Tests', () {
    test('fromJson and toJson should correctly map fields', () {
      final json = {
        'id': 'test-id-123',
        'organizador_id': 'org-id-123',
        'titulo': 'Limpieza de Playa',
        'categoria': 'Ambiental',
        'descripcion': 'Limpieza general de la playa',
        'fecha': '2026-10-01',
        'hora': '10:00',
        'latitud': 19.4326,
        'longitud': -99.1332,
        'direccion_referencia': 'Playa Central',
        'cupo_voluntarios': 50,
        'estado': 'activa',
        'estado_progreso': 'pendiente',
        'acepta_donaciones_dinero': true,
        'acepta_donaciones_articulos': false,
        'meta_donacion_dinero': 1000.0,
        'articulos_solicitados': ['Guantes', 'Bolsas'],
        'herramientas_necesarias': ['Pala'],
        'created_at': '2026-09-20T00:00:00Z',
      };

      final jornada = Jornada.fromJson(json);

      expect(jornada.id, 'test-id-123');
      expect(jornada.titulo, 'Limpieza de Playa');
      expect(jornada.categoria, 'Ambiental');
      expect(jornada.latitud, 19.4326);
      expect(jornada.longitud, -99.1332);
      expect(jornada.aceptaDonacionesDinero, true);
      expect(jornada.articulosSolicitados, ['Guantes', 'Bolsas']);
      expect(jornada.herramientasNecesarias, ['Pala']);

      final resultJson = jornada.toJson();
      expect(resultJson['titulo'], 'Limpieza de Playa');
      expect(resultJson['latitud'], 19.4326);
    });
  });
}
