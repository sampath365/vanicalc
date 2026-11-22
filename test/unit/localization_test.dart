import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Locale;
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/core/localization/app_localizations.dart';
import 'package:vanicalc/core/localization/translations.dart';
import 'package:vanicalc/core/localization/translations/en.dart';

void main() {
  test('every literal translation key used in the UI exists in English', () {
    final pattern = RegExp(r"""tr\(\s*'([^']+)'\s*\)""");
    final missing = <String>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final content = file.readAsStringSync();
      for (final match in pattern.allMatches(content)) {
        final key = match.group(1)!;
        if (!enStrings.containsKey(key)) {
          missing.add('$key (${file.path})');
        }
      }
    }

    expect(missing, isEmpty, reason: 'Missing English strings: $missing');
  });

  test('all ten languages are registered', () {
    expect(kTranslations.keys.toSet(), {
      'en',
      'te',
      'hi',
      'ta',
      'kn',
      'ml',
      'mr',
      'bn',
      'gu',
      'pa',
    });
    expect(AppLanguage.values, hasLength(10));
  });

  test('each language translates the navigation and core labels', () {
    const required = [
      'nav_home',
      'nav_calculator',
      'nav_history',
      'nav_tools',
      'nav_settings',
      'calc_result',
      'voice_title',
      'words_title',
      'history_title',
      'settings_title',
    ];
    for (final language in AppLanguage.values) {
      final localizations = AppLocalizations(language);
      for (final key in required) {
        expect(
          localizations.hasKey(key),
          isTrue,
          reason: '${language.code} is missing $key',
        );
        expect(localizations.tr(key), isNotEmpty);
      }
    }
  });

  test('translations differ from English for Indian languages', () {
    for (final language in AppLanguage.indianLanguages) {
      expect(
        AppLocalizations(language).tr('nav_home'),
        isNot('Home'),
        reason: '${language.code} should translate the home label',
      );
    }
  });

  test('missing keys fall back to English', () {
    final punjabi = AppLocalizations(AppLanguage.punjabi);
    expect(punjabi.hasKey('gst_inclusive'), isFalse);
    expect(punjabi.tr('gst_inclusive'), 'Amount includes GST');
  });

  test('unknown keys are returned verbatim', () {
    expect(
      const AppLocalizations(AppLanguage.english).tr('not.a.key'),
      'not.a.key',
    );
  });

  test('English strings are non-empty', () {
    for (final entry in enStrings.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('language metadata is complete', () {
    for (final language in AppLanguage.values) {
      expect(language.code, hasLength(2));
      expect(language.nativeName, isNotEmpty);
      expect(language.englishName, isNotEmpty);
      expect(language.speechLocale, contains('_'));
      expect(language.ttsLocale, contains('-'));
      expect(language.flag, isNotEmpty);
    }
  });

  test('supported locales cover every language', () {
    expect(AppLocalizations.supportedLocales, hasLength(10));
  });

  test('language lookup by code and locale', () {
    expect(AppLanguage.fromCode('te'), AppLanguage.telugu);
    expect(AppLanguage.fromCode('xx'), AppLanguage.english);
    expect(AppLanguage.fromCode(null), AppLanguage.english);
    expect(AppLanguage.fromLocale(const Locale('hi')), AppLanguage.hindi);
  });
}
