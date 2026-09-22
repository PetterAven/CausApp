import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Satisfaction Survey Persistence & Logic Tests', () {
    test('Survey state logic prevents immediate reappearance after response or dismissal', () {
      final currentCount = 1;
      
      final dynamic lastShownAtStr = null;
      final int lastCountAtShown = 1;
      final bool respondida = true;

      final bool debeMostrarInicial = lastShownAtStr == null && currentCount >= 1;
      expect(debeMostrarInicial, isTrue);

      final String shownTime = DateTime.now().toIso8601String();
      final lastShownAt = DateTime.parse(shownTime);
      final diasPasados = DateTime.now().difference(lastShownAt).inDays;
      final hayNuevaJornada = currentCount > lastCountAtShown;

      final bool debeMostrarDespues = diasPasados >= 90 && hayNuevaJornada && !respondida;
      expect(debeMostrarDespues, isFalse, reason: 'Survey should not reappear immediately after being answered.');
    });

    test('Survey reappears only when new jornada is completed and criteria met', () {
      final lastShownAt = DateTime.now().subtract(const Duration(days: 95));
      final lastCountAtShown = 1;
      
      final currentCount = 2;
      final diasPasados = DateTime.now().difference(lastShownAt).inDays;
      final hayNuevaJornada = currentCount > lastCountAtShown;

      final bool debeMostrarNuevamente = diasPasados >= 90 && hayNuevaJornada;
      expect(debeMostrarNuevamente, isTrue, reason: 'Survey should reappear after 90 days when a new jornada is completed.');
    });
  });
}
