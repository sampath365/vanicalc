# Upload VaniCalc to Google Play

**File to upload:** `deploy/VaniCalc-1.1.0-release.aab`
**Package:** `com.egan.vanicalc` · **Version:** 1.1.0 (code 2)
**SHA-256:** `865064a1c6bd8d288b34f36bcda7c1a7de74606922b638c8a64a829f72ef5e2e`

Download:
- https://github.com/sampath365/vanicalc/raw/main/deploy/VaniCalc-1.1.0-release.aab
- Test APK: https://github.com/sampath365/vanicalc/raw/main/deploy/VaniCalc-1.1.0-release.apk

Verify before uploading:

```bash
sha256sum VaniCalc-1.1.0-release.aab
# must print 865064a1...ef5e2e
```

## Privacy policy (required by Play)

Use this public URL in **Policy → App content → Privacy policy**:

```
https://github.com/sampath365/vanicalc/blob/main/docs/PRIVACY_POLICY.md
```

A styled standalone page is also available at `docs/privacy.html` if you host it on your own
domain later.

## 1. Create the app (one time)

Play Console → **All apps → Create app**

- App name: **VaniCalc — Smart Voice Calculator**
- Default language: **English (India)**
- App or game: **App**
- Free or paid: **Free**
- Accept the declarations → **Create app**

## 2. Upload the bundle

**Test and release → Testing → Internal testing → Create new release**

1. Upload `VaniCalc-1.1.0-release.aab`.
2. Release name: `1.1.0 (2)`.
3. Release notes (copy from `docs/STORE_LISTING.md`):

```
New: camera scan & count for barcodes, advanced maths tools (quadratic, statistics,
base converter, GCD/LCM, nCr/nPr, primes), searchable language and unit pickers,
live number words under the calculator, speak-on-equals, and a 19-category unit converter.
```

4. Add testers (your email), **Save → Review release → Start rollout to Internal testing**.
5. Install from the opt-in link and smoke-test on a real device.

## 3. Complete the store setup

**Grow → Store presence → Main store listing**

- Short description, full description: copy from `docs/STORE_LISTING.md`.
- App icon: 512×512 PNG (export from `assets/icon/app_icon.png`).
- Feature graphic: `docs/store/feature-graphic.png` (1024×500).
- Phone screenshots: use `docs/store/screenshots/phone_01…10` (10 images, 1170×2532).
- 7-inch tablet: `docs/store/screenshots/tablet7_01…02`.
- 10-inch tablet: `docs/store/screenshots/tablet10_01…02`.
- App icon: `docs/store/app-icon-512.png`.
- Feature graphic: `docs/store/feature-graphic.png`.

**Policy → App content**

| Section | Answer |
| --- | --- |
| Privacy policy | `https://github.com/sampath365/vanicalc/blob/main/docs/PRIVACY_POLICY.md` |
| Ads | No ads |
| App access | All functionality available without login |
| Content rating | Everyone / PEGI 3 (calculator, no user content) |
| Target audience | 13+ or 18+ (general tool) |
| Data safety | No data collected or shared; history/settings stored locally only. Mic and camera are processed on-device. |
| Government apps | No |
| Financial features | No (GST/EMI are offline calculators, not financial services) |
| Health | No |

## 4. Promote to production

1. Internal testing passes → **Closed testing** (optional) → **Production**.
2. Create a production release with the same AAB.
3. Choose countries, review, **Start rollout**.
4. First release with a new personal developer account may require a closed test with
   12+ testers for 14 days before production access.

## 5. After approval

- The listing goes live after review (usually 1–7 days).
- Tag the release:

```bash
git tag v1.1.0 && git push origin v1.1.0
```

## Troubleshooting

- **“Version code already used”** → bump `version: 1.1.0+2` in `pubspec.yaml` (e.g. `1.1.1+3`) and rebuild.
- **“App bundle was signed with the wrong key”** → the first upload must use the same
  upload key every time. The keystore is `android/app/upload-keystore.jks` (not in the repo);
  keep it backed up.
- **Camera/mic declarations** → Data safety must mention that audio is sent to the device
  speech service and camera frames are processed on-device by ML Kit; the app itself
  collects nothing.
