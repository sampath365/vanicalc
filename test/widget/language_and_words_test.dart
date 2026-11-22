import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/language/presentation/language_screen.dart';
import 'package:vanicalc/features/number_to_words/presentation/number_to_words_screen.dart';

import '../test_helpers.dart';

void main() {
  late TestEnvironment environment;

  setUp(() async {
    environment = await TestEnvironment.create();
  });

  tearDown(() async {
    await environment.dispose();
  });

  testWidgets('number to words shows Indian lakh and crore wording',
      (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const NumberToWordsScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Sixteen Lakh Thirty-Four Thousand Three Hundred Ninety-One',
      ),
      findsWidgets,
    );
  });

  testWidgets('switching to international numbering updates the words',
      (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const NumberToWordsScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('International'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Million'), findsWidgets);
  });

  testWidgets('currency mode appends rupees only', (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const NumberToWordsScreen(initialValue: '11800'),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Eleven Thousand Eight Hundred Rupees Only'),
      findsOneWidget,
    );
  });

  testWidgets('language screen switches the app language', (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const LanguageScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('తెలుగు'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(environment.preferences.getString('settings.language'), 'te');
    expect(find.text('Selected'), findsWidgets);
  });

  testWidgets('language screen filters by search', (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const LanguageScreen(),
        overrides: environment.overrides,
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'kannada');
    await tester.pump();

    expect(find.text('ಕನ್ನಡ'), findsOneWidget);
    expect(find.text('తెలుగు'), findsNothing);
  });

  testWidgets('language screen shows every supported language',
      (tester) async {

    await tester.pumpWidget(
      wrapForTest(
        const LanguageScreen(),
        overrides: environment.overrides,
        language: AppLanguage.hindi,
      ),
    );
    await tester.pump();

    expect(find.text('English'), findsWidgets);
    expect(find.text('తెలుగు'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('മലയാളം'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('മലയാളം'), findsWidgets);
  });
}
