import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/app.dart';
import 'package:vanicalc/features/calculator/presentation/calculator_screen.dart';
import 'package:vanicalc/features/home/presentation/home_screen.dart';
import 'package:vanicalc/features/home/presentation/splash_screen.dart';
import 'package:vanicalc/features/voice_calculator/presentation/voice_calculator_screen.dart';

import '../test_helpers.dart';

void main() {
  late TestEnvironment environment;

  setUp(() async {
    environment = await TestEnvironment.create(
      preferences: {'settings.onboarding_seen': true},
    );
  });

  tearDown(() async {
    await environment.dispose();
  });

  Future<void> boot(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: environment.overrides,
        child: const VaniCalcApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('boots through the splash screen into the dashboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: environment.overrides,
        child: const VaniCalcApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('VaniCalc'), findsWidgets);
  });

  testWidgets('dashboard opens the calculator', (tester) async {
    await boot(tester);

    await tester.tap(find.text('Standard and scientific keypad with memory'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CalculatorScreen), findsOneWidget);
  });

  testWidgets('dashboard opens the voice calculator', (tester) async {
    await boot(tester);

    await tester.tap(find.text('Voice Calculator'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(VoiceCalculatorScreen), findsOneWidget);
  });

  testWidgets('theme toggle persists a dark preference', (tester) async {
    await boot(tester);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(environment.preferences.getString('settings.theme'), 'dark');
  });
}
