# Release checklist

## Before building

- [ ] `flutter analyze` reports no issues
- [ ] `flutter test` is green (237 tests)
- [ ] Version bumped in `pubspec.yaml` (`version: 1.0.0+1`)
- [ ] `android/key.properties` and `android/app/upload-keystore.jks` present (never committed)
- [ ] Privacy policy published at the URL in `docs/STORE_LISTING.md`
- [ ] Store listing, screenshots and feature graphic uploaded

## Android

```bash
export JAVA_HOME=/path/to/jdk17
export ANDROID_HOME=/path/to/android-sdk
flutter build appbundle --release
```

- [ ] Verify the AAB is signed with the upload key (`jarsigner -verify -verbose -certs`)
- [ ] Upload `build/app/outputs/bundle/release/app-release.aab`
- [ ] Complete Data safety, content rating and target audience forms
- [ ] Roll out to internal testing, then closed, then production

## iOS

```bash
cd ios && pod install && cd ..
flutter build ipa --release
```

- [ ] Set the development team and bundle identifier `com.egan.vanicalc`
- [ ] Confirm microphone and speech usage descriptions appear in the build
- [ ] Upload with Transporter / Xcode Organizer
- [ ] Submit for review with the same privacy policy URL

## Post-release

- [ ] Tag the release: `git tag v1.0.0 && git push --tags`
- [ ] Monitor crash reports and Play vitals
- [ ] Keep the upload keystore backed up securely
