import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindo_app/main.dart';

void main() {
  testWidgets('Remindo smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RemindoApp(),
      ),
    );

    expect(find.text('Remindo'), findsWidgets);
  });
}
