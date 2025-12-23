// Basic Flutter widget test for Super App
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:super_app_boilerplate/main.dart';

void main() {
  testWidgets('App should render without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SuperApp(),
      ),
    );

    // Wait for splash screen animation
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that app renders
    expect(find.byType(SuperApp), findsOneWidget);
  });
}
