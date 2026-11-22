import 'package:material_ui/material_ui.dart';

import 'app_language.dart';
import 'translations.dart';

/// Lookup helper for translated strings with English fallback.
class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  String tr(String key) {
    final direct = kTranslations[language.code]?[key];
    if (direct != null && direct.isNotEmpty) return direct;
    return kTranslations['en']?[key] ?? key;
  }

  /// Whether this language has a dedicated table for [key].
  bool hasKey(String key) =>
      kTranslations[language.code]?.containsKey(key) ?? false;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(AppLanguage.english);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales =>
      AppLanguage.values.map((language) => language.locale).toList();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLanguage.values.any((language) => language.code == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(AppLanguage.fromLocale(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  AppLanguage get appLanguage => l10n.language;

  String tr(String key) => l10n.tr(key);
}
