# VaniCalc release binaries

Signed **1.0.0 (1)** builds, generated with Flutter 3.50.1 and Android SDK 36.

| File | Use |
| --- | --- |
| `VaniCalc-1.0.0-release.aab` | **Upload this to Google Play Console** (internal testing → production) |
| `VaniCalc-1.0.0-release.apk` | Universal APK for direct installation/sideloading on a device |
| `SHA256SUMS.txt` | Integrity checksums |

## Verify before installing

```bash
sha256sum -c SHA256SUMS.txt
```

## Signing

- Upload keystore alias: `egan`
- Certificate subject: `CN=EGAN, OU=Mobile, O=EGAN, L=Hyderabad, ST=Telangana, C=IN`
- Certificate SHA-256: `CE:7F:AF:14:92:EB:EB:68:26:39:B8:64:0C:EB:F5:A2:EC:7D:1B:E1:70:34:29:91:EB:7E:B1:E2:14:3F:C4:AA`
- `jarsigner -verify` reports **jar verified**

The private key and `android/key.properties` are **not** in this repository.

## Manifest

- Package `com.egan.vanicalc`
- versionName `1.0.0`, versionCode `1`
- minSdk 24, targetSdk 36, compileSdk 36
- ABIs in the bundle: `armeabi-v7a`, `arm64-v8a`, `x86_64`
- Permissions: `RECORD_AUDIO`, `INTERNET`, `ACCESS_NETWORK_STATE`, `MODIFY_AUDIO_SETTINGS`

## Install the APK

```bash
adb install -r VaniCalc-1.0.0-release.apk
```

## Rebuild

```bash
flutter build appbundle --release
flutter build apk --release
```

See `../docs/store/BUILD_ARTIFACTS.md` and `../docs/RELEASE_CHECKLIST.md` for the full release process.
