import 'package:flutter/widgets.dart';

/// Languages supported by the calculator UI, speech recognition and TTS.
enum AppLanguage {
  english(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    speechLocale: 'en_IN',
    ttsLocale: 'en-IN',
    flag: '🇬🇧',
  ),
  telugu(
    code: 'te',
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    speechLocale: 'te_IN',
    ttsLocale: 'te-IN',
    flag: '🇮🇳',
  ),
  hindi(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    speechLocale: 'hi_IN',
    ttsLocale: 'hi-IN',
    flag: '🇮🇳',
  ),
  tamil(
    code: 'ta',
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    speechLocale: 'ta_IN',
    ttsLocale: 'ta-IN',
    flag: '🇮🇳',
  ),
  kannada(
    code: 'kn',
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    speechLocale: 'kn_IN',
    ttsLocale: 'kn-IN',
    flag: '🇮🇳',
  ),
  malayalam(
    code: 'ml',
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    speechLocale: 'ml_IN',
    ttsLocale: 'ml-IN',
    flag: '🇮🇳',
  ),
  marathi(
    code: 'mr',
    englishName: 'Marathi',
    nativeName: 'मराठी',
    speechLocale: 'mr_IN',
    ttsLocale: 'mr-IN',
    flag: '🇮🇳',
  ),
  bengali(
    code: 'bn',
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    speechLocale: 'bn_IN',
    ttsLocale: 'bn-IN',
    flag: '🇮🇳',
  ),
  gujarati(
    code: 'gu',
    englishName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    speechLocale: 'gu_IN',
    ttsLocale: 'gu-IN',
    flag: '🇮🇳',
  ),
  punjabi(
    code: 'pa',
    englishName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    speechLocale: 'pa_IN',
    ttsLocale: 'pa-IN',
    flag: '🇮🇳',
  );

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.speechLocale,
    required this.ttsLocale,
    required this.flag,
  });

  final String code;
  final String englishName;
  final String nativeName;

  /// Locale identifier expected by `speech_to_text`.
  final String speechLocale;

  /// BCP-47 locale identifier expected by `flutter_tts`.
  final String ttsLocale;
  final String flag;

  Locale get locale => Locale(code);

  bool get isEnglish => this == AppLanguage.english;

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  /// Resolves a device locale (e.g. `te_IN`) to a supported language.
  static AppLanguage fromLocale(Locale locale) =>
      fromCode(locale.languageCode);

  static const List<AppLanguage> indianLanguages = [
    AppLanguage.telugu,
    AppLanguage.hindi,
    AppLanguage.tamil,
    AppLanguage.kannada,
    AppLanguage.malayalam,
    AppLanguage.marathi,
    AppLanguage.bengali,
    AppLanguage.gujarati,
    AppLanguage.punjabi,
  ];
}
