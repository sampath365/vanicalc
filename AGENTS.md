# AGENTS.md — VaniCalc repository guide

## Project

Flutter app (Android + iOS) named **VaniCalc**, package `com.egan.vanicalc`.
Flutter 3.50 / Dart 3.14, Material 3 via `package:material_ui` and `package:cupertino_ui`.

## Commands

```bash
flutter pub get
flutter analyze                  # must stay at 0 issues
flutter test                     # 237 tests
flutter run
flutter build appbundle --release
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Conventions

- Clean Architecture + MVVM. Domain code must not import Flutter widgets.
- State with Riverpod 3 `Notifier` / `NotifierProvider`; never `StateProvider`.
- Navigation with GoRouter; primary tabs live in a `StatefulShellRoute.indexedStack`.
- All user-facing strings go through `context.tr('key')` and exist in
  `lib/core/localization/translations/en.dart`. A test fails if a literal key is missing.
- Errors carry translation keys (see `CalcError`, `SpeechException`), not English text.
- Use `withValues(alpha: …)` instead of deprecated `withOpacity`.
- Keep the three engines independent: `ExpressionEngine`, `NumberToWordsEngine`,
  `SpokenMathParser`. Add tests with every behavioural change.

## Secrets

- `android/key.properties`, `android/app/upload-keystore.jks` and any `*.jks`/`*.keystore`
  are gitignored. Never commit or print their contents.
- Release builds fall back to the debug key when `key.properties` is absent.

## Tests

- Unit tests: `test/unit` (engines, repositories, settings, localization, voice controller).
- Widget tests: `test/widget` (keypad, voice, language, number words).
- Use `test/test_helpers.dart` for the in-memory history store and fake speech/TTS.
- Never do real file I/O inside `testWidgets`; the fake-async zone will hang.
