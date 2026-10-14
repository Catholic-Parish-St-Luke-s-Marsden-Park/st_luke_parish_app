# Google Play Console Onboarding

How an Android build gets from `main` into Google Play's **Internal testing**
track. This is the Android counterpart to
[app-store-connect-onboarding.md](app-store-connect-onboarding.md).

## Current state: manual upload

The `Android Release Build` workflow
([android-build.yml](../.github/workflows/android-build.yml)) builds and signs
an App Bundle (`.aab`) and attaches it to the run as an artifact. Uploading
that file to Play is a **manual** step. Play's API cannot create an app or
accept its first release, so automated upload is deferred until after the
first manual release (see [Next: automate upload](#next-automate-upload)).

| Field | Value |
|---|---|
| Package name | `au.org.stlukesmarsdenpark.st_luke_parish_app` |
| Firebase | `android/app/google-services.json` (committed, same package name) |
| Artifact | `app-release-aab` → `app-release.aab` |

> The package name is permanent once the Play listing is created. It must
> match `applicationId` in `android/app/build.gradle.kts` and the Firebase
> Android app registration.

## One-time setup

### 1. Play Console app

1. Sign in to <https://play.google.com/console> (developer account: one-off
   US$25 fee).
2. **Create app** with the name, default language, and "App", "Free".
3. **Testing → Internal testing → Testers**: create an email list and add
   tester Google accounts.

### 2. Upload keystore

Generate once and keep a backup somewhere safe (not the repo). The key is
gitignored (`**/*.jks`, `key.properties`).

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep Play App Signing enabled (the default): Google holds the real app
signing key, and this is only the *upload* key, so it can be reset through
Play support if lost.

### 3. GitHub secrets

Repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` (PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`) |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | key password |

The workflow fails fast with a clear error if any of these are unset.

## Releasing a build

1. GitHub → Actions → **Android Release Build** → Run workflow (pick a
   branch; default `main`).
2. When it finishes, download the `app-release-aab` artifact and unzip it.
3. Play Console → **Internal testing → Create new release** → upload
   `app-release.aab` → add release notes → **Save**, then **Review and roll
   out**.
4. Testers install from the opt-in link on the Internal testing page.

### Version numbers

- `versionName` comes from `version:` in `pubspec.yaml` (e.g. `1.0.0`).
- `versionCode` is the workflow run number (`--build-number`). Play rejects a
  duplicate or lower code, so re-running the same workflow for a new upload
  always works, but a manual upload with a higher code would need the run
  number to catch up.

## Local release build (optional)

To build a signed bundle locally, place the keystore at
`android/app/upload-keystore.jks` and create `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

Without `key.properties`, release builds fall back to the debug key, which
Play will reject but is fine for `flutter run --release`.

## Next: automate upload

After the first release exists in Play:

1. Google Cloud: create a service account, enable the *Google Play Android
   Developer API*, and create a JSON key.
2. Play Console → Users and permissions: invite the service account with
   release permission for this app.
3. Add a `PLAY_SERVICE_ACCOUNT_JSON` secret and a final workflow step using
   `r0adkll/upload-google-play` (or Fastlane `supply`) with
   `track: internal`.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "Missing required secret ..." | One of the four `ANDROID_*` secrets isn't set |
| Play: "signed with debug key" | Build ran without `key.properties`; use the workflow, not a local unsigned build |
| Play: "Version code already used" | Upload a build with a higher run number, or re-run the workflow |
| Play: "package name already exists" | Listing belongs to another account, or package name collision |
| Release-readiness gate fails | `assets/app.env` or release config check; see `test/release_readiness_test.dart` |
