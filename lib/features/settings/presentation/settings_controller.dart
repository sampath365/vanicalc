import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/app_settings.dart';

/// Owns [AppSettings] and persists every change.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> _persist(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  Future<void> setLanguage(AppLanguage language) =>
      _persist(state.copyWith(language: language));

  Future<void> setThemeMode(AppThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setAccent(AccentPalette accent) =>
      _persist(state.copyWith(accent: accent));

  Future<void> setNumberSystem(NumberSystem system) =>
      _persist(state.copyWith(numberSystem: system));

  Future<void> setAutoSpeak(bool value) =>
      _persist(state.copyWith(autoSpeak: value));

  Future<void> setHaptics(bool value) =>
      _persist(state.copyWith(haptics: value));

  Future<void> setLargeText(bool value) =>
      _persist(state.copyWith(largeText: value));

  Future<void> setSpeechRate(double value) =>
      _persist(state.copyWith(speechRate: value));

  Future<void> setSpeechPitch(double value) =>
      _persist(state.copyWith(speechPitch: value));

  Future<void> setSpeechLanguage(AppLanguage? language) => _persist(
    language == null
        ? state.copyWith(clearSpeechLanguage: true)
        : state.copyWith(speechLanguage: language),
  );

  Future<void> setTtsLanguage(AppLanguage? language) => _persist(
    language == null
        ? state.copyWith(clearTtsLanguage: true)
        : state.copyWith(ttsLanguage: language),
  );

  Future<void> markOnboardingSeen() =>
      _persist(state.copyWith(onboardingSeen: true));

  Future<void> reset() async {
    await ref.read(settingsRepositoryProvider).reset();
    state = const AppSettings();
  }
}
