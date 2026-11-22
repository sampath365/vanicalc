import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/voice_calculator/presentation/voice_calculator_screen.dart';

import '../test_helpers.dart';

void main() {
  late TestEnvironment environment;

  setUp(() async {
    environment = await TestEnvironment.create();
  });

  tearDown(() async {
    await environment.dispose();
  });

  String resultText(WidgetTester tester) {
    final widget = tester.widget<Text>(
      find.byKey(const Key('voice_result_text')),
    );
    return widget.data ?? '';
  }

  testWidgets('microphone starts listening and the result is spoken', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapForTest(
        const VoiceCalculatorScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();
    await tester.pump();

    expect(environment.recognizer.listening, isTrue);
    expect(environment.recognizer.lastLocale, 'en_US');

    environment.recognizer.emit('What is 25 plus 35?');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('voice_result_text')), findsOneWidget);
    expect(resultText(tester), '60');
    expect(environment.synthesizer.spoken, isNotEmpty);
    expect(environment.synthesizer.spoken.last, contains('Sixty'));
  });

  testWidgets('example chips calculate without the microphone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapForTest(
        const VoiceCalculatorScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    final chip = find.text('Multiply 25 by 10');
    await tester.scrollUntilVisible(
      chip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(resultText(tester), '250');
  });

  testWidgets('shows an error for unclear speech', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapForTest(
        const VoiceCalculatorScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();
    await tester.pump();
    environment.recognizer.emit('banana');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Invalid expression'), findsWidgets);
  });

  testWidgets('renders in Hindi', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrapForTest(
        const VoiceCalculatorScreen(),
        overrides: environment.overrides,
        language: AppLanguage.hindi,
      ),
    );
    await tester.pump();

    expect(find.text('वॉइस कैलकुलेटर'), findsWidgets);
  });
}
