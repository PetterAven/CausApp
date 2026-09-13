import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:causapp/main.dart';

void main() {
  testWidgets('CausApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: CausApp()));
  });
}
