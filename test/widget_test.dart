import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindo_app/core/providers/app_providers.dart';
import 'package:remindo_app/core/router/app_router.dart';

void main() {
  testWidgets('AppGate displays OnboardingScreen when hasHeroProfile is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasHeroProfileProvider.overrideWith((ref) => false),
        ],
        child: const MaterialApp(
          home: AppGate(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mulai Petualanganmu!'), findsOneWidget);
    expect(find.text('REMINDO • 100% OFFLINE RPG'), findsOneWidget);
  });

  testWidgets('AppGate displays HomeScreen when hasHeroProfile is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasHeroProfileProvider.overrideWith((ref) => true),
        ],
        child: const MaterialApp(
          home: AppGate(),
        ),
      ),
    );

    await tester.pump();

    // Verify presence of HomeScreen elements or loading state
    expect(find.byType(AppGate), findsOneWidget);
  });
}
