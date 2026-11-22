import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/app_settings.dart';

/// Reads and writes [AppSettings] to platform preferences.
class SettingsRepository {
  const SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _languageKey = 'settings.language';
  static const _themeKey = 'settings.theme';
  static const _accentKey = 'settings.accent';
  static const _numberSystemKey = 'settings.number_system';
  static const _autoSpeakKey = 'settings.auto_speak';
  static const _hapticsKey = 'settings.haptics';
  static const _largeTextKey = 'settings.large_text';
  static const _onboardingKey = 'settings.onboarding_seen';
  static const _speechRateKey = 'settings.speech_rate';
  static const _speechPitchKey = 'settings.speech_pitch';
  static const _speechLanguageKey = 'settings.speech_language';
  static const _ttsLanguageKey = 'settings.tts_language';

  AppSettings load() {
    final speechCode = _prefs.getString(_speechLanguageKey);
    final ttsCode = _prefs.getString(_ttsLanguageKey);
    return AppSettings(
      language: AppLanguage.fromCode(_prefs.getString(_languageKey)),
      themeMode: AppThemeMode.fromKey(_prefs.getString(_themeKey)),
      accent: AccentPalette.fromKey(_prefs.getString(_accentKey)),
      numberSystem: NumberSystem.fromKey(_prefs.getString(_numberSystemKey)),
      autoSpeak: _prefs.getBool(_autoSpeakKey) ?? true,
      haptics: _prefs.getBool(_hapticsKey) ?? true,
      largeText: _prefs.getBool(_largeTextKey) ?? false,
      onboardingSeen: _prefs.getBool(_onboardingKey) ?? false,
      speechRate: _prefs.getDouble(_speechRateKey) ?? 0.5,
      speechPitch: _prefs.getDouble(_speechPitchKey) ?? 1.0,
      speechLanguage: speechCode == null
          ? null
          : AppLanguage.fromCode(speechCode),
      ttsLanguage: ttsCode == null ? null : AppLanguage.fromCode(ttsCode),
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_languageKey, settings.language.code);
    await _prefs.setString(_themeKey, settings.themeMode.key);
    await _prefs.setString(_accentKey, settings.accent.key);
    await _prefs.setString(_numberSystemKey, settings.numberSystem.key);
    await _prefs.setBool(_autoSpeakKey, settings.autoSpeak);
    await _prefs.setBool(_hapticsKey, settings.haptics);
    await _prefs.setBool(_largeTextKey, settings.largeText);
    await _prefs.setBool(_onboardingKey, settings.onboardingSeen);
    await _prefs.setDouble(_speechRateKey, settings.speechRate);
    await _prefs.setDouble(_speechPitchKey, settings.speechPitch);
    if (settings.speechLanguage == null) {
      await _prefs.remove(_speechLanguageKey);
    } else {
      await _prefs.setString(_speechLanguageKey, settings.speechLanguage!.code);
    }
    if (settings.ttsLanguage == null) {
      await _prefs.remove(_ttsLanguageKey);
    } else {
      await _prefs.setString(_ttsLanguageKey, settings.ttsLanguage!.code);
    }
  }

  Future<void> reset() async {
    await _prefs.remove(_languageKey);
    await _prefs.remove(_themeKey);
    await _prefs.remove(_accentKey);
    await _prefs.remove(_numberSystemKey);
    await _prefs.remove(_autoSpeakKey);
    await _prefs.remove(_hapticsKey);
    await _prefs.remove(_largeTextKey);
    await _prefs.remove(_speechRateKey);
    await _prefs.remove(_speechPitchKey);
    await _prefs.remove(_speechLanguageKey);
    await _prefs.remove(_ttsLanguageKey);
  }
}
