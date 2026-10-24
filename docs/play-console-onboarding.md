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

Do this only after the first release has been uploaded **manually** (see
[Releasing a build](#releasing-a-build)). Play's API cannot create the app
listing or accept its very first bundle; it can only add releases to an app
that already has one. Until then, the steps below will fail with
"Package not found".

The end result: running **Android Release Build** builds, signs, *and*
uploads the bundle to Internal testing, with no manual download/upload.

### 1. Create the service account (Google Cloud)

1. Open <https://console.cloud.google.com> and pick (or create) a project.
   Any project works; a dedicated one such as `st-lukes-parish-ci` keeps the
   permissions easy to audit. It does not need to be the Firebase project.
2. **APIs & Services → Library** → search **Google Play Android Developer
   API** → **Enable**.
3. **IAM & Admin → Service Accounts → Create service account**.
   - Name: `play-publisher` (any name).
   - Skip the optional "Grant this service account access to project" step.
     Project-level IAM roles are not what grants Play access (step 2 does).
4. Open the new account → **Keys → Add key → Create new key → JSON**. A `.json`
   file downloads once; Google keeps no copy.
5. Note the account's email
   (`play-publisher@<project>.iam.gserviceaccount.com`); you need it next.

> Treat the JSON key like a password. Never commit it. If your Google
> organisation blocks key creation ("Service account key creation is
> disabled"), an org admin must lift the
> `iam.disableServiceAccountKeyCreation` policy for this project.

### 2. Grant the account access in Play Console

Play access is separate from Google Cloud IAM.

1. Play Console → **Users and permissions → Invite new users**.
2. Email: the service account email from the previous step.
3. **App permissions → Add app** → select St Luke's.
4. Under that app's permissions tick **Release to testing tracks** (enough for
   Internal testing). Add **Release apps to production** only if you later
   automate production.
5. **Invite user**. Service accounts accept automatically; there is no email
   to click.

Permission changes can take a few minutes (occasionally longer) to propagate.
If the first run returns a 403 immediately after this step, wait and re-run.

### 3. Add the GitHub secret

Repo → Settings → Secrets and variables → Actions → **New repository secret**:

| Secret | Value |
|---|---|
| `PLAY_SERVICE_ACCOUNT_JSON` | The **entire contents** of the downloaded `.json` file, pasted as-is (not base64) |

Then delete the downloaded file from your machine (or move it into your
password manager).

### 4. Add the upload step to the workflow

In [android-build.yml](../.github/workflows/android-build.yml), add this
after the `upload-artifact` step. Keep the artifact step: it is your backup
copy and lets you manually upload if the API step fails.

```yaml
      - name: Upload to Play Internal testing
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: au.org.stlukesmarsdenpark.st_luke_parish_app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```

Notes on the inputs:

- `track: internal` is the Internal testing track. Use `alpha` (closed
  testing) or `production` later by changing this one value.
- `status: completed` rolls the release out to testers immediately. Use
  `status: draft` if you want the upload to land as a draft you review and roll
  out by hand in the Console. **Use `draft` while the app itself is still in
  Play's draft state** (never published to any track beyond internal/review);
  Play rejects `completed` releases on an app that hasn't completed its setup
  tasks, with "Only releases with status draft may be created on draft app".
- Optional: `releaseName` (defaults to the version name) and
  `whatsNewDirectory` (a folder of `whatsnew-en-AU` text files) to attach
  release notes. Without notes, Play accepts the release with none.
- The `versionCode` already comes from `--build-number=${{ github.run_number }}`,
  so no extra versioning work is needed. Because Play requires strictly
  increasing codes, a manual upload made *after* automation starts must use a
  code above the current run number, or the next workflow run will be
  rejected.
- Pin the action to a full version tag (e.g. `@v1.x.y`) or commit SHA if you
  want reproducible builds; `@v1` floats.

Optionally, gate it behind a workflow input so a run can build without
uploading:

```yaml
on:
  workflow_dispatch:
    inputs:
      branch: { ... }
      upload:
        description: "Upload the bundle to Play Internal testing"
        type: boolean
        default: true
```

then add `if: ${{ inputs.upload }}` to the upload step.

### 5. Verify

1. Run **Android Release Build** from GitHub Actions.
2. Confirm the **Upload to Play Internal testing** step is green.
3. Play Console → **Testing → Internal testing → Releases**: the new version
   code appears (processing can take a few minutes).
4. Install from the opt-in link and confirm the new build.

### Alternative: Fastlane `supply`

`r0adkll/upload-google-play` is the simpler fit for a single-track upload with
no extra tooling. Fastlane `supply` is worth it only if you also want
automated store-listing/metadata/screenshot uploads, at the cost of adding
Ruby, a `Gemfile`, and a `fastlane/` directory to a repo that currently has
none. Its auth is the same service account JSON.

### Security notes

- The key only has release rights on this one app; it cannot read financial
  data or manage users.
- Restrict who can edit workflows (branch protection / CODEOWNERS on
  `.github/`), since anyone who can change the workflow can use the secret.
- Rotate the key if it is ever exposed: Cloud Console → the service account →
  Keys → delete the old key, create a new one, update the secret.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "Missing required secret ..." | One of the four `ANDROID_*` secrets isn't set |
| Play: "signed with debug key" | Build ran without `key.properties`; use the workflow, not a local unsigned build |
| Play: "Version code already used" | Upload a build with a higher run number, or re-run the workflow |
| Play: "package name already exists" | Listing belongs to another account, or package name collision |
| Upload step: "Package not found" | No manual first release exists yet, or `packageName` doesn't match the listing |
| Upload step: 403 / "caller does not have permission" | Service account not invited in Play Console, lacks **Release to testing tracks** for this app, or the invite hasn't propagated yet |
| Upload step: "Google Play Android Developer API has not been used" | API not enabled in the Cloud project that owns the service account |
| Upload step: "Only releases with status draft may be created on draft app" | Set `status: draft` until the app's setup tasks are complete |
| Release-readiness gate fails | `assets/app.env` or release config check; see `test/release_readiness_test.dart` |
