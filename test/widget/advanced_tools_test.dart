import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/features/tools/presentation/advanced_tools_screen.dart';
import 'package:vanicalc/shared/widgets/searchable_dropdown.dart';

import '../test_helpers.dart';

void main() {
  late TestEnvironment environment;

  setUp(() async {
    environment = await TestEnvironment.create();
  });

  tearDown(() async {
    await environment.dispose();
  });

  testWidgets('quadratic screen solves the default equation', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const QuadraticScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    expect(find.text('Discriminant'), findsOneWidget);
    expect(find.text('Root 1'), findsOneWidget);
    expect(find.text('Root 2'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('statistics screen computes mean and median', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const StatisticsScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    expect(find.text('Mean'), findsOneWidget);
    expect(find.text('Median'), findsOneWidget);
    expect(find.text('30'), findsWidgets);
    expect(find.text('Count'), findsOneWidget);
  });

  testWidgets('base converter shows every base', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const BaseConverterScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    expect(find.text('Binary'), findsOneWidget);
    expect(find.text('Octal'), findsOneWidget);
    expect(find.text('Hexadecimal'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('number tools computes gcd, nCr and primes', (tester) async {
    await tester.pumpWidget(
      wrapForTest(const NumberToolsScreen(), overrides: environment.overrides),
    );
    await tester.pump();

    expect(find.text('GCD'), findsOneWidget);
    expect(find.text('LCM'), findsOneWidget);
    expect(find.text('Combinations (nCr)'), findsOneWidget);
    expect(find.text('Prime'), findsOneWidget);
    expect(find.text('97'), findsWidgets);
  });

  testWidgets('searchable dropdown filters and selects', (tester) async {
    String? selected;
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: Center(
            child: SearchableDropdown<String>(
              label: 'Unit',
              value: 'Meter',
              options: const [
                SearchableOption(value: 'Meter', label: 'Meter'),
                SearchableOption(value: 'Kilometre', label: 'Kilometre'),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(SearchableDropdown<String>));
    await tester.pumpAndSettle();
    expect(find.text('Kilometre'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kilo');
    await tester.pump();
    expect(find.widgetWithText(ListTile, 'Meter'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Kilometre'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Kilometre'));
    await tester.pumpAndSettle();
    expect(selected, 'Kilometre');
  });
}
