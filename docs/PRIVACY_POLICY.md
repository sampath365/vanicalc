# VaniCalc Privacy Policy

**Last updated: 22 November 2026**

VaniCalc ("the app") is published by EGAN Labs. This policy explains what the app does with your
information. The short version: **the app has no accounts, no ads, no analytics and no server of
its own. Your calculations never leave your device.**

## Information the app stores

- **Calculation history** — expressions, results, timestamps, language and type are stored in a
  local database (Hive) inside the app's private storage.
- **Preferences** — theme, accent colour, language, numbering system, speech rate/pitch and
  auto-speak are stored locally with Android SharedPreferences / iOS UserDefaults.

This data stays on your device. It is removed when you clear it in the app or uninstall the app.

## Microphone and speech recognition

Voice input requires the microphone permission. When you tap the microphone, audio is sent to the
speech recognition service provided by your device or operating system (for example Google's
speech service on Android or Apple's speech framework on iOS). That processing is governed by the
privacy policy of that provider. VaniCalc itself does not upload, store or transmit your audio or
transcripts. Recognition results are converted into a maths expression locally.

## Camera and barcode scanning

The scan & count tool uses the camera only while that screen is open. Barcode frames are
processed on-device by Google ML Kit and are not stored or transmitted by VaniCalc. Camera
access is optional; items can always be entered manually.

## Text-to-speech

Results are read aloud using the text-to-speech engine installed on your device. The text sent to
the engine is generated locally from your calculation.

## Permissions

| Permission | Why it is used |
| --- | --- |
| Microphone (`RECORD_AUDIO`) | Voice calculations |
| Camera (`CAMERA`) | Optional barcode scanning for the scan & count tool; frames are processed on-device by ML Kit and are never uploaded by VaniCalc |
| Internet / network state | Only used by the platform speech recogniser when it needs online recognition; the app itself makes no network calls |
| Modify audio settings | Audio focus while speaking |

## Sharing

When you tap Share, the app hands the selected text to your device's share sheet. You choose the
destination; the app does not share anything automatically.

## Children

The app is a general-purpose calculator and does not knowingly collect personal information from
anyone, including children.

## Data deletion

Clear individual entries or the whole history from the History screen, or uninstall the app to
remove all locally stored data. There is no server-side data to delete.

## Changes

If this policy changes, the updated version will be published at this location with a new date.

## Contact

Questions about privacy: **support@eganlabs.com**
