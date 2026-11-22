import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// User preferences persisted with `SharedPreferences`.
class AppSettings {
  const AppSettings({
    this.language = AppLanguage.english,
    this.themeMode = AppThemeMode.system,
    this.accent = AccentPalette.orange,
    this.numberSystem = NumberSystem.indian,
    this.autoSpeak = true,
    this.haptics = true,
    this.largeText = false,
    this.onboardingSeen = false,
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.speechLanguage,
    this.ttsLanguage,
  });

  final AppLanguage language;
  final AppThemeMode themeMode;
  final AccentPalette accent;
  final NumberSystem numberSystem;
  final bool autoSpeak;
  final bool haptics;
  final bool largeText;
  final bool onboardingSeen;
  final double speechRate;
  final double speechPitch;

  /// Optional overrides; `null` means "follow the app language".
  final AppLanguage? speechLanguage;
  final AppLanguage? ttsLanguage;

  AppLanguage get effectiveSpeechLanguage => speechLanguage ?? language;
  AppLanguage get effectiveTtsLanguage => ttsLanguage ?? language;

  AppSettings copyWith({
    AppLanguage? language,
    AppThemeMode? themeMode,
    AccentPalette? accent,
    NumberSystem? numberSystem,
    bool? autoSpeak,
    bool? haptics,
    bool? largeText,
    bool? onboardingSeen,
    double? speechRate,
    double? speechPitch,
    AppLanguage? speechLanguage,
    AppLanguage? ttsLanguage,
    bool clearSpeechLanguage = false,
    bool clearTtsLanguage = false,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      numberSystem: numberSystem ?? this.numberSystem,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      haptics: haptics ?? this.haptics,
      largeText: largeText ?? this.largeText,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      speechLanguage:
          clearSpeechLanguage ? null : (speechLanguage ?? this.speechLanguage),
      ttsLanguage:
          clearTtsLanguage ? null : (ttsLanguage ?? this.ttsLanguage),
    );
  }
}
