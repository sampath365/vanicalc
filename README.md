# VaniCalc — Smart Voice Calculator

<p align="center">
  <img src="assets/icon/app_icon.png" width="132" alt="VaniCalc icon" />
</p>

<p align="center">
  <b>A premium Flutter calculator that listens, speaks and writes numbers in ten Indian languages.</b><br/>
  Standard &amp; scientific keypad · Voice maths · Offline number-to-words · Text-to-speech · GST &amp; financial tools
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.14-0175C2?logo=dart&logoColor=white" />
  <img alt="Platforms" src="https://img.shields.io/badge/Android%20%7C%20iOS-ready-FF7A18" />
  <img alt="Tests" src="https://img.shields.io/badge/tests-272%20passing-12B76A" />
  <img alt="License" src="https://img.shields.io/badge/license-MIT-101828" />
</p>

---

## Download

- [VaniCalc 1.1.0 — Play upload bundle (AAB)](deploy/VaniCalc-1.1.0-release.aab)
- [VaniCalc 1.1.0 — universal APK](deploy/VaniCalc-1.1.0-release.apk)
- [SHA-256 checksums](deploy/SHA256SUMS.txt)

The binaries are signed with the project upload key; see [`deploy/README.md`](deploy/README.md).

## Why VaniCalc

Most calculator apps are either a plain keypad or a thin wrapper around a web view.
VaniCalc keeps **three independent, fully local engines**:

| Engine | Responsibility | Never needs internet |
| --- | --- | --- |
| **Calculation engine** | Tokenising, parsing and evaluating maths with correct precedence, percentages, functions and guarded errors | ✅ |
| **Number-to-words engine** | English, Telugu, Hindi, Tamil, Kannada, Malayalam, Marathi, Bengali, Gujarati and Punjabi with Indian (lakh/crore) and international grouping, decimals, negatives and currency | ✅ |
| **Voice engine** | Speech-to-text → spoken-maths parser → calculator; results read back through device TTS | Recognition may use the platform service; parsing is local |

That separation keeps each engine small, testable and replaceable — and it means the app still
works in aeroplane mode for everything except online speech recognition.

## Feature tour

### Calculator
- Addition, subtraction, multiplication, division, modulus, percentage, powers, factorial, π, e
- Square root, cube root, squares, cubes, reciprocal, brackets, implicit multiplication (`2(3+4)`, `2π`)
- Memory (`MC`, `MR`, `M+`, `M−`), delete, AC, sign toggle
- Live preview while typing, live number words under the display, animated result
- Speak-on-equals when auto-speak is on, plus a speak/stop button in the display
- Scientific mode with trigonometry, logarithms, `sin/cos/tan`, `log/ln`, `xʸ`, `1/x`
- Friendly, translated errors: divide by zero, domain errors, factorial limits, overflow

### Voice calculator
Say things like:

```
What is 25 plus 35?
Calculate 500 minus 150
Multiply 25 by 10
Divide 1000 by 5
What is 15 percent of 200?
Add 500, 200 and 300
What is the square root of 144?
Calculate 25 multiplied by 4 and add 100
```

The screen shows live recognition, the interpreted expression (editable), confidence, and the
spoken answer. Ambiguous input asks for confirmation instead of guessing.

Voice commands: *Clear calculator*, *Delete last number*, *Repeat answer*, *Show history*,
*Switch to scientific calculator*, *Change language to Telugu*, *Read result in Hindi*.

### Ten languages
English, తెలుగు, हिन्दी, தமிழ், ಕನ್ನಡ, മലയാളം, मराठी, বাংলা, ગુજરાતી, ਪੰਜਾਬੀ.

- Entire navigation, calculator, voice, words, history and settings UI translated
- Speech recognition and TTS use language-specific locales when the device supports them
- Graceful fallback (and a visible notice) when a device has no recogniser for a language
- English digits always work, even with another language selected
- Language choice is persisted and applies instantly

### Number to words
| Number | English (Indian) |
| --- | --- |
| 100 | One Hundred |
| 1,000 | One Thousand |
| 10,000 | Ten Thousand |
| 1,00,000 | One Lakh |
| 10,00,000 | Ten Lakh |
| 1,00,00,000 | One Crore |
| 16,34,391 | Sixteen Lakh Thirty-Four Thousand Three Hundred Ninety-One |

Also supports international grouping (million/billion), decimals, negatives, and currency
(`₹11,800 → Eleven Thousand Eight Hundred Rupees Only`). Copy, share and speak are one tap away.

### History
Hive-backed, searchable, favouritable, with reuse, copy, speak and delete. Daily statistics
appear on the dashboard. The last 500 calculations are kept.

### Financial & everyday tools
GST (add/remove, 5/12/18/28% + custom, CGST/SGST/IGST breakup, amount in words), discount,
profit & loss, EMI, simple & compound interest, tip split, ratio, fraction, percentage,
age and date difference. Several fields accept **spoken input**.

### Advanced maths
Quadratic equation solver (real and complex roots, discriminant), statistics (count, sum,
mean, median, mode, variance, standard deviation, min/max), base converter (binary, octal,
decimal, hexadecimal) and number tools (GCD/LCM, nPr/nCr, prime check and prime factors).

### Scan & count
Point the camera at item barcodes to tally stock or purchases. Each scan increments the
item count, prices are optional, and the screen shows total items, total amount, the amount
in words, speech output and a one-tap save to history. Camera access is optional — items can
be added manually when no camera is available.

### Unit converter
19 categories: length, mass, temperature, area, volume, speed, time, data, pressure, energy,
power, angle, frequency, force, torque, acceleration, density, flow rate and illuminance.
Unit pickers are searchable.

### Design
Premium white (and true dark) UI, orange accent with four alternatives, large rounded keys with
soft shadows, animated microphone orb, responsive phone/tablet layouts, bottom navigation and a
floating microphone button. Accessibility: semantic keypad labels and a larger-text option.

## Screens

The complete screen list: splash, onboarding, dashboard, standard calculator, scientific
calculator, voice calculator, speak result, number to words, GST, unit converter, history,
tools hub, percentage, discount, profit & loss, EMI, interest, tip, ratio, fraction, age,
date difference, quadratic solver, statistics, base converter, number tools, scan & count,
language selection and settings.

## Getting started

```bash
git clone https://github.com/sampath365/vanicalc.git
cd vanicalc
flutter pub get
flutter run
```

Requirements: Flutter **3.50+** / Dart **3.14+**, Android SDK 36 for Android builds, Xcode 16+
for iOS. The app targets Android 36 (minSdk 24) and iOS 13+.

### Generate icons and splash (already committed)

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Quality gates

```bash
flutter analyze     # 0 issues
flutter test        # 272 tests
```

## Architecture

```
lib/
  main.dart                  # bootstrap: prefs, Hive, ProviderScope
  app.dart                   # MaterialApp.router: theme, locale, text scale
  app_providers.dart         # dependency graph (Riverpod)
  core/
    constants/               # app metadata, numbering systems
    errors/                  # typed, translation-keyed exceptions
    localization/            # AppLanguage, 10 translation tables, delegate
    router/                  # GoRouter + StatefulShellRoute
    services/                # speech, TTS, clipboard/share/haptics
    theme/                   # colour palette, ThemeData, CalcPalette extension
    utils/                   # result + date formatting
  features/
    calculator/              # engine, controller (MVVM), keypad, screen
    voice_calculator/        # spoken-maths parser, controller, screen
    number_to_words/         # engine + 10 language implementations
    history/                 # store interface, Hive repository, controller
    settings/                # settings model, repository, controller, screen
    gst/                     # financial calculators + GST screen
    converter/               # 19-category unit conversion + searchable pickers
    tools/                   # maths/finance/advanced tools + shared tool widgets
    scanner/                 # barcode scan & count domain + camera screen
    home/ language/ speak/   # dashboard, onboarding, splash, language, speak
  shared/
    widgets/                 # SurfaceCard, FeatureCard, GradientButton, keypad…
    voice_input.dart         # spoken number capture for tool fields
```

- **Clean Architecture** — domain logic (engines, models) has no Flutter imports; data and
  presentation depend inward.
- **MVVM + Riverpod** — `Notifier` controllers own state; screens are thin views.
- **GoRouter** — `StatefulShellRoute.indexedStack` keeps each tab's state; feature screens push
  on top of the shell.
- **Storage** — Hive for history (behind a `HistoryStore` interface), SharedPreferences for settings.

## Testing

272 tests cover:

- Every calculator operation, precedence, implicit multiplication, percentages, functions
- Divide-by-zero, domain, factorial, overflow and bracket errors
- Number words in all ten languages, Indian/international grouping, decimals, negatives, currency
- Spoken maths in English, Hindi, Telugu, Tamil, Kannada and Malayalam; commands and unclear input
- GST, discount, profit/loss, EMI, interest, percentage, ratio, fraction and date maths
- Unit conversions (length, weight, temperature, area, volume, speed, time, data)
- History repository (search, favourites, pruning, corrupt entries)
- Advanced maths: quadratic (real/complex), statistics, base conversion, GCD/LCM, nCr/nPr, primes
- Scan counter: duplicate scans, quantities, prices, decrement/remove and totals
- Settings persistence and language overrides
- Widget tests for keypad arithmetic, live words, auto-speak, scientific powers, memory, reuse,
  error display, voice recognition → result → speech, language switching, number-to-words
  output, advanced tools and searchable dropdowns

```bash
flutter test test/unit
flutter test test/widget
```

## Build & release

### Android

Create `android/key.properties` (never commit it):

```properties
storePassword=…
keyPassword=…
keyAlias=egan
storeFile=upload-keystore.jks
```

Put the upload keystore at `android/app/upload-keystore.jks`, then:

```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
flutter build apk --release --split-per-abi
```

If `key.properties` is absent the release build falls back to the debug key so CI can still
produce artifacts; **Play Store uploads must use the upload key**.

### iOS

```bash
cd ios && pod install && cd ..
flutter build ipa --release
```

Set your team in Xcode, then upload with Transporter. Microphone and speech usage descriptions
are already present in `Info.plist`.

## Store assets

- `assets/icon/app_icon.png` — 1024×1024 launcher icon
- `assets/icon/app_icon_foreground.png` — adaptive icon foreground
- `assets/icon/splash_logo.png` — splash mark
- `docs/store/feature-graphic.png` — 1024×500 Play Store feature graphic
- `docs/STORE_LISTING.md` — title, short/full description, data-safety notes
- `docs/PRIVACY_POLICY.md` — ready-to-publish privacy policy

## Known limitations

- Scan & count reads **barcodes/QR codes**, not arbitrary objects or handwritten bills.
- Speech recognition quality depends on the device recogniser. Some Android devices only offer
  online recognition for certain Indian languages; VaniCalc detects missing locales and tells the
  user instead of failing silently.
- TTS voice availability is device dependent. If a language is unavailable the engine falls back
  to English rather than staying silent.
- Number words cover up to trillions; expressions are evaluated in double precision with a
  12-significant-digit display.
- Advanced tool labels fall back to English in the four less-common UI translations; the
  calculator, voice, words, history and settings surfaces are fully translated in all ten.

## Contributing

Issues and pull requests are welcome. Run `flutter analyze` and `flutter test` before opening a PR.
See `AGENTS.md` for repository conventions.

## License

MIT © 2026 EGAN Labs. See [LICENSE](LICENSE).
