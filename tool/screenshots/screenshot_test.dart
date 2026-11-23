import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/calculator/presentation/calculator_screen.dart';
import 'package:vanicalc/features/converter/presentation/unit_converter_screen.dart';
import 'package:vanicalc/features/gst/presentation/gst_calculator_screen.dart';
import 'package:vanicalc/features/history/presentation/history_screen.dart';
import 'package:vanicalc/features/home/presentation/home_screen.dart';
import 'package:vanicalc/features/number_to_words/presentation/number_to_words_screen.dart';
import 'package:vanicalc/features/settings/presentation/settings_screen.dart';
import 'package:vanicalc/features/tools/presentation/tools_screen.dart';
import 'package:vanicalc/features/voice_calculator/presentation/voice_calculator_screen.dart';

import '../../test/test_helpers.dart';

const _phone = Size(1170, 2532);

Future<void> _loadFont(String family, List<String> files) async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/workspace/sdk/flutter';
  final directory = Directory('$root/bin/cache/artifacts/material_fonts');
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = await File('${directory.path}/$file').readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  late TestEnvironment environment;

  setUpAll(() async {
    await _loadFont('Roboto', ['Roboto-Regular.ttf']);
    await _loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
  });

  setUp(() async {
    environment = await TestEnvironment.create();
  });

  tearDown(() async {
    await environment.dispose();
  });

  Future<void> configure(
    WidgetTester tester, [
    Size size = _phone,
    double pixelRatio = 3,
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> capture(
    WidgetTester tester,
    Widget screen,
    String name, {
    AppLanguage language = AppLanguage.english,
    Size size = _phone,
    double pixelRatio = 3,
  }) async {
    debugDisableShadows = false;
    await configure(tester, size, pixelRatio);
    await tester.pumpWidget(
      wrapForTest(
        screen,
        overrides: environment.overrides,
        language: language,
        useRobotoFont: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
    debugDisableShadows = true;
  }

  testWidgets('01 dashboard', (tester) async {
    await capture(tester, const HomeScreen(), '01_dashboard');
  });

  testWidgets('02 calculator', (tester) async {
    debugDisableShadows = false;
    await configure(tester);
    await tester.pumpWidget(
      wrapForTest(const CalculatorScreen(), overrides: environment.overrides),
    );
    await tester.pump();
    for (final key in ['7', '+', '8', '=']) {
      await tester.tap(find.byKey(ValueKey('calc_key_$key')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/02_calculator.png'),
    );
    debugDisableShadows = true;
  });

  testWidgets('03 voice', (tester) async {
    debugDisableShadows = false;
    await configure(tester);
    await tester.pumpWidget(
      wrapForTest(
        const VoiceCalculatorScreen(),
        overrides: environment.overrides,
        useRobotoFont: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();
    await tester.pump();
    environment.recognizer.emit('What is 25 plus 35?');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/03_voice.png'),
    );
    debugDisableShadows = true;
  });

  testWidgets('04 number to words', (tester) async {
    await capture(tester, const NumberToWordsScreen(), '04_number_to_words');
  });

  testWidgets('05 gst', (tester) async {
    await capture(tester, const GstCalculatorScreen(), '05_gst');
  });

  testWidgets('06 scientific', (tester) async {
    debugDisableShadows = false;
    await configure(tester);
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(scientific: true),
        overrides: environment.overrides,
        useRobotoFont: true,
      ),
    );
    await tester.pump();
    for (final key in ['2', '^', '1', '0', '=']) {
      await tester.tap(find.byKey(ValueKey('calc_key_$key')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/06_scientific.png'),
    );
    debugDisableShadows = true;
  });

  testWidgets('07 tools', (tester) async {
    await capture(tester, const ToolsScreen(), '07_tools');
  });

  testWidgets('08 converter', (tester) async {
    await capture(tester, const UnitConverterScreen(), '08_converter');
  });

  testWidgets('09 history', (tester) async {
    await environment.history.add(
      expression: '25+35',
      result: '60',
      type: 'standard',
      languageCode: 'en',
      value: 60,
      createdAt: DateTime(2026, 11, 22, 14, 30),
    );
    await environment.history.add(
      expression: '1000*18%',
      result: '180',
      type: 'gst',
      languageCode: 'en',
      value: 180,
      createdAt: DateTime(2026, 11, 22, 13, 10),
    );
    await environment.history.add(
      expression: 'sqrt(144)',
      result: '12',
      type: 'scientific',
      languageCode: 'en',
      value: 12,
      createdAt: DateTime(2026, 11, 21, 18, 5),
    );
    await capture(tester, const HistoryScreen(), '09_history');
  });

  testWidgets('10 settings', (tester) async {
    await capture(tester, const SettingsScreen(), '10_settings');
  });

  testWidgets('11 seven inch dashboard', (tester) async {
    await capture(
      tester,
      const HomeScreen(),
      '11_dashboard_7',
      size: const Size(1200, 1920),
      pixelRatio: 2,
    );
  });

  testWidgets('12 seven inch calculator', (tester) async {
    debugDisableShadows = false;
    await configure(tester, const Size(1200, 1920), 2);
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(),
        overrides: environment.overrides,
        useRobotoFont: true,
      ),
    );
    await tester.pump();
    for (final key in ['7', '+', '8', '=']) {
      await tester.tap(find.byKey(ValueKey('calc_key_$key')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/12_calculator_7.png'),
    );
    debugDisableShadows = true;
  });

  testWidgets('13 ten inch dashboard', (tester) async {
    await capture(
      tester,
      const HomeScreen(),
      '13_dashboard_10',
      size: const Size(1600, 2560),
      pixelRatio: 2,
    );
  });

  testWidgets('14 ten inch calculator', (tester) async {
    debugDisableShadows = false;
    await configure(tester, const Size(1600, 2560), 2);
    await tester.pumpWidget(
      wrapForTest(
        const CalculatorScreen(),
        overrides: environment.overrides,
        useRobotoFont: true,
      ),
    );
    await tester.pump();
    for (final key in ['7', '+', '8', '=']) {
      await tester.tap(find.byKey(ValueKey('calc_key_$key')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/14_calculator_10.png'),
    );
    debugDisableShadows = true;
  });
}
