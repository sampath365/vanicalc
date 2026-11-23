# Play Store screenshots

Rendered from the real Flutter UI with `tool/screenshots/screenshot_test.dart`
(`flutter test --update-goldens tool/screenshots/screenshot_test.dart`), then converted to
24-bit RGB PNG.

## Phone (1170 × 2532, 9:19.5)

| File | Screen |
| --- | --- |
| `phone_01_dashboard.png` | Dashboard |
| `phone_02_calculator.png` | Standard calculator (7 + 8 = 15, words) |
| `phone_03_voice_calculator.png` | Voice calculator (recognised 25 + 35) |
| `phone_04_number_to_words.png` | Number to words (16,34,391) |
| `phone_05_gst.png` | GST calculator (₹10,000 + 18%) |
| `phone_06_scientific.png` | Scientific calculator (2¹⁰ = 1024) |
| `phone_07_tools.png` | Tools hub (scan & count, finance, maths) |
| `phone_08_converter.png` | Unit converter |
| `phone_09_history.png` | Calculation history |
| `phone_10_settings.png` | Settings |

## 7-inch tablet (1200 × 1920)

`tablet7_01_dashboard.png`, `tablet7_02_calculator.png`

## 10-inch tablet (1600 × 2560)

`tablet10_01_dashboard.png`, `tablet10_02_calculator.png`

## Other listing assets

- `../app-icon-512.png` — 512 × 512 app icon
- `../feature-graphic.png` — 1024 × 500 feature graphic

## Regenerate

```bash
flutter test --update-goldens tool/screenshots/screenshot_test.dart
python3 - <<'PY'
from PIL import Image
# convert tool/screenshots/goldens/*.png to RGB in docs/store/screenshots/
PY
```
