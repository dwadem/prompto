# Deployment & CI/CD

This project ships with two GitHub Actions workflows in `.github/workflows/`.

| Workflow | File | Trigger | What it does |
|---|---|---|---|
| **CI** | `ci.yml` | every PR + push to `main` | `flutter pub get` → `flutter analyze` → `flutter test` |
| **Release build** | `release.yml` | tag `v*` or manual dispatch | builds a release **APK** + **AAB**, uploads them as artifacts |

> Because this prototype is cross-platform code only (the `android/` and `ios/`
> folders are git-ignored and regenerated with `flutter create`), the CI job
> needs no platform folders, and the release job regenerates `android/` on the fly.

---

## 1. Continuous Integration (`ci.yml`)

This is effectively the **first real compile** of the app. Every pull request and
every push to `main` runs static analysis and the unit-test suite on a clean
Ubuntu runner with the stable Flutter channel.

- **Pin the Flutter version** for full reproducibility by replacing
  `channel: stable` with `flutter-version: 3.27.0` (or your target) in the
  `subosito/flutter-action@v2` step.
- If `flutter analyze` flags style-only issues you don't want to gate on, add
  `--no-fatal-infos` to the analyze step.

## 2. Release build (`release.yml`)

Trigger it two ways:

```bash
# Tag-based (recommended): cut a version and push the tag.
git tag v0.1.0
git push origin v0.1.0
```

…or from the **Actions** tab → *Release build (Android)* → **Run workflow**.

The run produces, as downloadable artifacts:
- `app-release.apk` — sideloadable for quick testing.
- `app-release.aab` — the App Bundle format Google Play expects.

> **Signing:** if the keystore secrets in §3 are configured, the workflow signs
> release builds with your **upload key** automatically. If they're absent, it
> falls back to **DEBUG signing** — fine for testing, but not accepted by the
> Play Store. No credential ever lives in the repo; secrets are read at runtime.

---

## 3. Going to production on Google Play

To turn the release pipeline into a real Play deployment:

### 3.1 Commit the `android/` folder
Stop regenerating it on every build so your signing/config is version-controlled:

```bash
flutter create --platforms=android --org com.yourcompany --project-name prompto .
# Remove the /android/ line from .gitignore, then:
git add android && git commit -m "Add Android platform config"
```

Set a real `applicationId`, `versionCode`/`versionName`, and target SDK in
`android/app/build.gradle(.kts)`.

**Launcher icon.** The source art lives in `assets/icon/` (regenerate with
`python3 scripts/generate_icon.py`). After the platform folders exist, generate
the per-density icons:

```bash
dart run flutter_launcher_icons
```

For the Play **store listing** (separate from the launcher icon) export a 512×512
PNG. Listing copy, required graphics, and the data-safety/content-rating checklist
are in `docs/STORE_LISTING.md`; a privacy-policy template is in
`docs/PRIVACY_POLICY.md` (host it and paste the URL into the console).

### 3.2 Create an upload keystore

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep this file **out of the repo**. See Flutter's
[“Build and release an Android app”](https://docs.flutter.dev/deployment/android).

### 3.3 Store secrets in GitHub
Repo → **Settings → Secrets and variables → Actions**:

- `ANDROID_KEYSTORE_BASE64` — `base64 -w0 upload-keystore.jks`
- `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
- `PLAY_SERVICE_ACCOUNT_JSON` — a Google Play service-account key with
  *Release manager* access (only needed later, for automated upload).

> 🔒 Create these yourself and paste them **only** into GitHub's encrypted
> secrets — never into source, chat, or logs. CI reads them at build time.

### 3.3a How signing is wired (automatic)
`release.yml` already handles signing: when `ANDROID_KEYSTORE_BASE64` is set it
decodes the keystore, writes `android/key.properties`, and runs
`scripts/configure_android_signing.py` to inject a release `signingConfig` into
the generated `android/app/build.gradle.kts`. With no secret it debug-signs.
If you later commit a permanent `android/` folder, move that signing block into
`build.gradle.kts` directly and drop the patch step.

### 3.4 Sign + upload in the workflow
In `release.yml`, after building, decode the keystore from the secret, write
`key.properties`, then upload with
[`r0adkll/upload-google-play`](https://github.com/r0adkll/upload-google-play):

```yaml
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.yourcompany.prompto
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal   # internal → closed → open → production
```

Use the `internal` track first for testers, then promote.

---

## 4. iOS (when you add it)

iOS builds require a **macOS runner** (`runs-on: macos-latest`) and Apple
credentials. The recommended path is **fastlane match** for certificates +
provisioning, and `fastlane pilot`/`deliver` for TestFlight/App Store. You'll
also commit an `ios/` folder (`flutter create --platforms=ios .`), set the
bundle id and team in Xcode, and add any `NS*UsageDescription` keys to
`Info.plist` (see the iOS section of the main `README.md`). Apple Developer
Program membership and signing certificates are prerequisites.

---

## Quick reference

```bash
# Validate locally before pushing (needs Flutter 3.27+):
flutter pub get && flutter analyze && flutter test

# Cut a release build via CI:
git tag v0.1.0 && git push origin v0.1.0
```
