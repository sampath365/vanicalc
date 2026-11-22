# Build artifacts — 1.0.0 (1)

Built on 22 November 2026 with Flutter 3.50.1 / Dart 3.14.0 and Android SDK 36.

| Artifact | Path | Size | SHA-256 |
| --- | --- | --- | --- |
| Play upload bundle | `build/app/outputs/bundle/release/app-release.aab` | 58.7 MB | `7aa62f32e52691abb2cb72d3bdd41c26974837608fc6cf2cfc7dee68c9c71ec9` |
| Universal release APK | `build/app/outputs/flutter-apk/app-release.apk` | 60.2 MB | `1c65c122497afda4019e21eba0ded17363a21d2808c5d2e79279bcfc3cf3afec` |

The artifacts live under `build/`, which is gitignored. Rebuild them with:

```bash
flutter build appbundle --release
flutter build apk --release
```

## Signing

- Keystore: upload keystore (PKCS#12), alias `egan`
- Certificate subject: `CN=EGAN, OU=Mobile, O=EGAN, L=Hyderabad, ST=Telangana, C=IN`
- Certificate SHA-256: `CE:7F:AF:14:92:EB:EB:68:26:39:B8:64:0C:EB:F5:A2:EC:7D:1B:E1:70:34:29:91:EB:7E:B1:E2:14:3F:C4:AA`
- `jarsigner -verify` reports **jar verified**
- The keystore and `android/key.properties` are **not** in the repository

## Manifest summary

- Package: `com.egan.vanicalc`
- versionName `1.0.0`, versionCode `1`
- minSdk 24, targetSdk 36, compileSdk 36
- ABIs in the bundle: `armeabi-v7a`, `arm64-v8a`, `x86_64`
- Permissions: `RECORD_AUDIO`, `INTERNET`, `ACCESS_NETWORK_STATE`, `MODIFY_AUDIO_SETTINGS`
- Application label: `VaniCalc`
- Queries: `RecognitionService`, `TTS_SERVICE`, `PROCESS_TEXT`
