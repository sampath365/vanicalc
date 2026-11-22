import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/app_providers.dart';
import 'package:vanicalc/core/constants/number_system.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/core/theme/app_colors.dart';
import 'package:vanicalc/core/theme/app_theme.dart';
import 'package:vanicalc/features/settings/domain/app_settings.dart';

import '../test_helpers.dart';

void main() {
  group('defaults', () {
    test('English, system theme, Indian numbering, speech on', () async {
      final container = await createTestContainer();
      final settings = container.read(settingsControllerProvider);
      expect(settings.language, AppLanguage.english);
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.accent, AccentPalette.orange);
      expect(settings.numberSystem, NumberSystem.indian);
      expect(settings.autoSpeak, isTrue);
      expect(settings.haptics, isTrue);
      expect(settings.largeText, isFalse);
      expect(settings.onboardingSeen, isFalse);
      expect(settings.speechRate, 0.5);
      expect(settings.speechPitch, 1.0);
    });

    test('reads stored preferences', () async {
      final container = await createTestContainer(
        preferences: {
          'settings.language': 'te',
          'settings.theme': 'dark',
          'settings.accent': 'blue',
          'settings.number_system': 'international',
          'settings.auto_speak': false,
          'settings.haptics': false,
          'settings.onboarding_seen': true,
        },
      );
      final settings = container.read(settingsControllerProvider);
      expect(settings.language, AppLanguage.telugu);
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.accent, AccentPalette.blue);
      expect(settings.numberSystem, NumberSystem.international);
      expect(settings.autoSpeak, isFalse);
      expect(settings.haptics, isFalse);
      expect(settings.onboardingSeen, isTrue);
    });
  });

  group('updates', () {
    test('language change is persisted and follows speech output', () async {
      final container = await createTestContainer();
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setLanguage(AppLanguage.tamil);
      final settings = container.read(settingsControllerProvider);
      expect(settings.language, AppLanguage.tamil);
      expect(settings.effectiveSpeechLanguage, AppLanguage.tamil);
      expect(settings.effectiveTtsLanguage, AppLanguage.tamil);
      expect(
        container.read(sharedPreferencesProvider).getString('settings.language'),
        'ta',
      );
    });

    test('speech and TTS languages can be overridden independently', () async {
      final container = await createTestContainer();
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setSpeechLanguage(AppLanguage.hindi);
      await notifier.setTtsLanguage(AppLanguage.kannada);
      var settings = container.read(settingsControllerProvider);
      expect(settings.effectiveSpeechLanguage, AppLanguage.hindi);
      expect(settings.effectiveTtsLanguage, AppLanguage.kannada);
      expect(settings.language, AppLanguage.english);

      await notifier.setSpeechLanguage(null);
      settings = container.read(settingsControllerProvider);
      expect(settings.effectiveSpeechLanguage, AppLanguage.english);
    });

    test('theme, accent and numbering persist', () async {
      final container = await createTestContainer();
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setThemeMode(AppThemeMode.light);
      await notifier.setAccent(AccentPalette.teal);
      await notifier.setNumberSystem(NumberSystem.international);
      final settings = container.read(settingsControllerProvider);
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.accent, AccentPalette.teal);
      expect(settings.numberSystem, NumberSystem.international);
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('settings.theme'), 'light');
      expect(prefs.getString('settings.accent'), 'teal');
      expect(prefs.getString('settings.number_system'), 'international');
    });

    test('speech rate and pitch are clamped by the UI and stored', () async {
      final container = await createTestContainer();
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setSpeechRate(0.8);
      await notifier.setSpeechPitch(1.4);
      final settings = container.read(settingsControllerProvider);
      expect(settings.speechRate, 0.8);
      expect(settings.speechPitch, 1.4);
    });

    test('reset restores defaults', () async {
      final container = await createTestContainer(
        preferences: {'settings.language': 'hi', 'settings.theme': 'dark'},
      );
      await container.read(settingsControllerProvider.notifier).reset();
      final settings = container.read(settingsControllerProvider);
      expect(settings.language, AppLanguage.english);
      expect(settings.themeMode, AppThemeMode.system);
    });
  });

  group('model', () {
    test('copyWith clears overrides', () {
      const settings = AppSettings(
        speechLanguage: AppLanguage.telugu,
        ttsLanguage: AppLanguage.hindi,
      );
      final cleared = settings.copyWith(
        clearSpeechLanguage: true,
        clearTtsLanguage: true,
      );
      expect(cleared.speechLanguage, isNull);
      expect(cleared.ttsLanguage, isNull);
      expect(cleared.effectiveSpeechLanguage, AppLanguage.english);
    });
  });
}
