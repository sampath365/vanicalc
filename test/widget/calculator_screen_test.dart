import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/calculator/presentation/calculator_screen.dart';

import '../test_helpers.dart';

void main() {
  late TestEnvironment environment;

  setUp(() async {
    environment = await TestEnvironment.create();
  });

  tearDown(() async {
    await environment.dispose();
  });

  Future<void> tapKey(WidgetTester tester, String value) async {
    await tester.tap(find.byKey(ValueKey('calc_key_$value')));
    await tester.pump();
  }

  Future<void> tapFn(WidgetTester tester, String value) async {
    await tester.tap(find.byKey(ValueKey('calc_fn_$value')));
    await tester.pump();
  }

  String display(WidgetTester tester) {
    final widgets = tester
        .widgetList<Text>(find.byKey(const Key('calc_display_result')))
        .toList();
    return widgets.isEmpty ? '' : (widgets.last.data ?? '');
  }

  testWidgets('adds two numbers with the keypad', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapKey(tester, '7');
    await tapKey(tester, '+');
    await tapKey(tester, '8');
    await tapKey(tester, '=');

    expect(display(tester), '15');
    expect(environment.history.all(), hasLength(1));
  });

  testWidgets('respects operator precedence', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapKey(tester, '2');
    await tapKey(tester, '+');
    await tapKey(tester, '3');
    await tapKey(tester, '*');
    await tapKey(tester, '4');
    await tapKey(tester, '=');

    expect(display(tester), '14');
  });

  testWidgets('clear resets the expression', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapKey(tester, '9');
    await tapKey(tester, '+');
    await tapKey(tester, '1');
    await tapKey(tester, 'AC');

    expect(display(tester), '0');
  });

  testWidgets('divide by zero shows an error', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapKey(tester, '5');
    await tapKey(tester, '/');
    await tapKey(tester, '0');
    await tapKey(tester, '=');

    expect(display(tester), 'Cannot divide by zero');
  });

  testWidgets('scientific keypad computes a power', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(scientific: true),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tapKey(tester, '2');
    await tapKey(tester, '^');
    await tapKey(tester, '3');
    await tapKey(tester, '=');

    expect(display(tester), '8');
  });

  testWidgets('square root shortcut works', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapFn(tester, 'sqrt(');
    await tapKey(tester, '1');
    await tapKey(tester, '4');
    await tapKey(tester, '4');
    await tapKey(tester, ')');
    await tapKey(tester, '=');

    expect(display(tester), '12');
  });

  testWidgets('memory stores and recalls a value', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    await tapKey(tester, '4');
    await tapKey(tester, '2');
    await tester.tap(find.text('M+'));
    await tester.pump();
    await tapKey(tester, 'AC');
    await tester.tap(find.text('MR'));
    await tester.pump();

    expect(find.text('42'), findsWidgets);
  });

  testWidgets('loads a reused expression', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(initialExpression: '25*4'),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('100'), findsWidgets);
  });

  testWidgets('renders in Telugu', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(),
        overrides: environment.overrides,
        language: AppLanguage.telugu,
      ),
    );
    await tester.pump();

    expect(find.text('కాలిక్యులేటర్'), findsWidgets);
  });
}
