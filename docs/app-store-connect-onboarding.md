# App Store Connect Onboarding

A plain-language guide to Apple's release tooling for anyone on this project
who hasn't used App Store Connect before. It covers what the pieces are, how
a build gets from `main` into TestFlight, and how to fix the most common
first-time problems.

## What is App Store Connect?

App Store Connect (<https://appstoreconnect.apple.com>) is Apple's portal for
managing an app's release lifecycle: metadata, screenshots, pricing,
TestFlight builds, and App Store submissions. It's separate from — but
linked to — the **Apple Developer** portal
(<https://developer.apple.com/account>), which manages lower-level account
resources: App IDs (bundle identifiers), certificates, and provisioning
profiles.

This app's record:

| Field | Value |
|---|---|
| App name | St Luke Parish App |
| Apple ID | `6821571661` |
| SKU | `st-luke-parish-app-ios-001` |
| Bundle ID | `au.org.stlukesmarsdenpark.parishapp` |
| Team | Catholic Parish of St Luke's Marsden Park |
| Team ID | `F5QH8M7RG6` |

## What is TestFlight?

TestFlight is Apple's beta-testing system, built into App Store Connect. A
build uploaded from CI (or from Xcode) goes through a short automated
**processing** step (usually a few minutes, sometimes up to an hour), after
which it's available to **testers** — real people with the TestFlight app on
their phone — without going through full App Store review first (a very
light **Beta App Review** only applies the first time you add *external*
testers, see below).

Flow: **upload → processing → appears under TestFlight → testers install it**.

## The "Certificates, Identifiers & Profiles" page

This is the Apple Developer portal screen for lower-level account resources.
Three concepts matter here:

- **App ID / Bundle ID** — the unique identifier for the app, e.g.
  `au.org.stlukesmarsdenpark.parishapp`. This value must be **identical** in
  three places: the Apple Developer App ID, the App Store Connect app
  record, and the Xcode project's `PRODUCT_BUNDLE_IDENTIFIER`. If any one of
  these drifts from the others, uploads fail or land against the wrong app.
  (This project shipped with exactly this mismatch — see
  [Troubleshooting](#troubleshooting) below for the worked example.)
- **Capabilities** — features the app is allowed to use, enabled per App ID.
  This app has **Push Notifications** enabled (visible as a checked
  capability on the App ID's configuration page), which is what lets
  `ios/Runner/Runner.entitlements`' `aps-environment` key actually work on a
  real device.
- **Certificates** and **Provisioning Profiles** — a certificate proves who
  built the app (tied to the Apple Developer account/team); a provisioning
  profile ties a certificate, an App ID, and (for App Store distribution) a
  list of allowed capabilities together into something Xcode can sign a
  build with. This project stores both as base64-encoded GitHub secrets,
  exported once by a human and imported into a temporary CI keychain on each
  run — see [One-time setup](#one-time-setup-a-human-must-do-before-this-works).

## Finding and adding testers in TestFlight

In App Store Connect, open the app → **TestFlight** tab:

- **Internal testers** — anyone who's a member of the App Store Connect team
  with an appropriate role (e.g. Admin, App Manager, Developer). Add them
  under **Internal Testing**; they get access to new builds almost
  immediately, no review needed.
- **External testers** — anyone else, added by email or via a public
  TestFlight link, grouped under **External Testing** groups. The **first**
  build sent to an external group needs a quick **Beta App Review** (usually
  under a day); after that, new builds to the same group don't need review
  again unless the app's permissions/capabilities change significantly.

## How the GitHub Action fits in

The workflow doesn't run automatically on push — trigger it manually from
**Actions → iOS TestFlight → Run workflow**, optionally typing a branch name
(defaults to `main` if left blank). That runs
`.github/workflows/ios-testflight.yml`, which:

1. Checks out the repo and sets up Flutter
2. Runs `flutter analyze` and the release-readiness gate
3. Installs CocoaPods dependencies
4. Builds a release `.ipa` with `flutter build ipa`
5. Uploads it to TestFlight via Fastlane

Watch it run under the repo's **Actions** tab. Once the **Upload to
TestFlight** step finishes, the new build appears in App Store Connect under
**TestFlight → iOS Builds** a few minutes later (Apple's own processing
time), ready to assign to testers.

## One-time setup a human must do before this works

These steps are deliberately **not** automated — they require a human with
Apple Developer admin access, and only need to be done once (or again when a
secret/cert expires).

1. **Generate an App Store Connect API key** — App Store Connect →
   **Users and Access → Integrations → App Store Connect API** → create a
   key with at least the "App Manager" role. Apple lets you download the
   `.p8` private key file **once** — save it securely. Note the **Key ID**
   and **Issuer ID** shown on the same page.

   **Only the Account Holder can request API access.** If "Request Access"
   is greyed out on this page, you're not the Account Holder — check
   **Users and Access → People** to find who is, and ask them to grant it
   (or generate the key themselves). While waiting, see
   [Temporary option: Apple ID auth](#temporary-option-apple-id-auth-while-waiting-on-account-holder-access)
   below for a fallback that doesn't need this.
2. **Export an Apple Distribution certificate as a `.p12`** — an **Apple
   Development** certificate (the kind Xcode creates automatically for
   running on test devices) will **not** work here; App Store Connect
   rejects builds signed with it. You need a separate **Apple Distribution**
   certificate.

   Generate a CSR and private key with `openssl`, run somewhere **outside
   the git repo** (the private key must never be committed):
   ```bash
   mkdir -p ~/ios-certs && cd ~/ios-certs

   # 2048-bit RSA key, Apple's required size for distribution certs
   openssl genrsa -out ios_distribution.key 2048

   openssl req -new -key ios_distribution.key \
     -out ios_distribution.certSigningRequest \
     -subj "/emailAddress=you@example.com/CN=Your Name/C=AU"

   # Import the key into your login keychain so it's ready to pair with
   # the certificate once Apple issues it
   security import ios_distribution.key -k ~/Library/Keychains/login.keychain-db
   ```
   Then:
   1. Upload `ios_distribution.certSigningRequest` at
      <https://developer.apple.com/account/resources/certificates/add>,
      choosing certificate type **"Apple Distribution"**.
   2. Download the resulting `.cer` and double-click it — it pairs
      automatically with the key just imported, showing up in Keychain
      Access under **login → My Certificates** as something like
      "Apple Distribution: Catholic Parish of St Luke's Marsden Park
      (F5QH8M7RG6)".
   3. Export it as a `.p12`, either from Keychain Access (right-click the
      certificate entry → **Export**), or entirely from the terminal:
      ```bash
      # Apple's .cer download is DER-encoded; convert to PEM first
      openssl x509 -inform DER -in distribution.cer -out distribution.pem

      openssl pkcs12 -export \
        -inkey ios_distribution.key \
        -in distribution.pem \
        -out distribution.p12 \
        -name "Apple Distribution: Catholic Parish of St Luke's Marsden Park"
      ```
      Either way, set an export password when prompted — that password
      becomes the `IOS_DIST_CERTIFICATE_PASSWORD` secret below.

   Delete `ios_distribution.key` and `distribution.p12` from disk once
   they're safely in GitHub secrets (or keep them somewhere secure outside
   the repo) — anyone with the key file can sign builds as this
   organization.
3. **Download the App Store provisioning profile** — Apple Developer portal
   → **Certificates, Identifiers & Profiles → Profiles → +** → under
   **Distribution**, choose **"App Store Connect"** (the current name for
   what's commonly still called "App Store" distribution — this is the one
   `ExportOptions.plist`'s `method: app-store` expects) → select the
   `au.org.stlukesmarsdenpark.parishapp` App ID → select the certificate
   from step 2 → give it a clear, stable name, e.g. "St Luke Parish App App
   Store" (the exact name doesn't matter — the Fastfile reads it back
   dynamically at build time rather than expecting a specific string) →
   **Generate**, then **Download** the `.mobileprovision` file.
4. **Re-download `GoogleService-Info.plist` for the corrected bundle ID** —
   the committed file's `BUNDLE_ID` still references the old identifier
   (`au.org.stlukesmarsdenpark.stLukeParishApp`). In the Firebase console
   (project `st-luke-s-parish-app`), add/select an iOS app registered under
   `au.org.stlukesmarsdenpark.parishapp`, download its `GoogleService-Info.plist`,
   and replace `ios/Runner/GoogleService-Info.plist` with it. Until this is
   done, push notifications may silently fail to register.
5. **Add the GitHub repository secrets** — under
   **Settings → Secrets and variables → Actions**:

   | Secret | Where it comes from |
   |---|---|
   | `ASC_KEY_ID` | Step 1, "Key ID" |
   | `ASC_ISSUER_ID` | Step 1, "Issuer ID" |
   | `ASC_KEY_CONTENT` | Step 1's `.p8` file, base64-encoded: `base64 -i AuthKey_XXXX.p8 \| pbcopy` |
   | `IOS_DIST_CERTIFICATE_P12` | Step 2's `.p12` file, base64-encoded: `base64 -i distribution.p12 \| pbcopy` |
   | `IOS_DIST_CERTIFICATE_PASSWORD` | The export password chosen in step 2 |
   | `IOS_PROVISIONING_PROFILE` | Step 3's `.mobileprovision` file, base64-encoded: `base64 -i St_Luke_Parish_App_App_Store.mobileprovision \| pbcopy` |
   | `FASTLANE_TEAM_ID` | `F5QH8M7RG6` |

   CI imports the certificate and profile into a fresh temporary keychain on
   every run (`ios/fastlane/Fastfile` → `beta` lane) — nothing about them is
   stored in the repo itself, only as these secrets.

## Temporary option: Apple ID auth (while waiting on Account Holder access)

If the Account Holder hasn't granted API access yet, Fastlane can
authenticate as your own Apple ID instead of a Team API key — this doesn't
need Account Holder approval, just your own App Manager/Admin login. The
`beta` lane in `ios/fastlane/Fastfile` automatically falls back to this path
whenever the `ASC_KEY_ID` secret isn't set.

1. Generate an app-specific password at <https://appleid.apple.com>
   (**Sign-In and Security → App-Specific Passwords**).
2. Locally run `spaceauth` once, through Bundler (fastlane is a project
   dependency declared in `ios/Gemfile`, not a global command — run
   `bundle install` first if you haven't), to go through 2FA interactively
   and produce a session cookie:
   ```bash
   cd ios
   bundle install   # first time only, installs into ios/vendor/bundle (gitignored)
   bundle exec fastlane spaceauth -u your@appleid.com
   ```
   Use the app-specific password from step 1 when prompted, then enter the
   2FA code sent to your device.
3. Add three GitHub secrets instead of the three `ASC_*` ones:

   | Secret | Where it comes from |
   |---|---|
   | `FASTLANE_APPLE_ID` | The Apple ID email used above |
   | `FASTLANE_PASSWORD` | The app-specific password from step 1 |
   | `FASTLANE_SESSION` | The session cookie printed by `fastlane spaceauth` in step 2 |

**Downside:** the session cookie periodically expires and has to be
regenerated by hand, since interactive 2FA can't run in CI — this is a
reasonable bridge while waiting on the Account Holder, not a good permanent
setup. Switch back to the API key (remove the three `FASTLANE_*` secrets,
add the three `ASC_*` ones) as soon as access is granted.

## Rotating secrets

- **App Store Connect API key expires or is revoked** — repeat step 1 above,
  generate a new key, update `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_CONTENT`.
- **Certificate expires or is revoked** (Apple Distribution certs last 1
  year) — repeat step 2 above to export a fresh `.p12`, update
  `IOS_DIST_CERTIFICATE_P12` and `IOS_DIST_CERTIFICATE_PASSWORD`.
- **Provisioning profile expires** (up to 1 year) — repeat step 3 above to
  download a fresh `.mobileprovision`, update `IOS_PROVISIONING_PROFILE`.
  Regenerate it whenever the certificate above is rotated too, since a
  profile is tied to a specific certificate.

## Troubleshooting

- **Bundle ID / App ID mismatch** — exactly the issue this project shipped
  with: the Xcode project said `au.org.stlukesmarsdenpark.stLukeParishApp`
  while App Store Connect and the Apple Developer App ID said
  `au.org.stlukesmarsdenpark.parishapp`. Symptom: uploads are rejected, or
  silently create a *second* app record instead of updating the existing
  one. Fix: make `PRODUCT_BUNDLE_IDENTIFIER` in
  `ios/Runner.xcodeproj/project.pbxproj` match the bundle ID already
  registered in App Store Connect — never the other way around once an app
  record exists.
- **"No identity found" / certificate import fails** — usually means
  `IOS_DIST_CERTIFICATE_P12` or `IOS_DIST_CERTIFICATE_PASSWORD` is stale,
  wasn't base64-encoded correctly, or the certificate itself expired or was
  revoked. Re-export per [Rotating secrets](#rotating-secrets) and update
  both secrets together.
- **"Doesn't match any profile" / profile doesn't cover the app** — the
  `IOS_PROVISIONING_PROFILE` secret is stale, was generated for the old
  bundle ID, or doesn't match the certificate currently in
  `IOS_DIST_CERTIFICATE_P12`. Download a fresh profile for
  `au.org.stlukesmarsdenpark.parishapp` against the current certificate and
  update the secret.
- **Archiving manually in Xcode (not via CI) fails on provisioning** — the
  committed `PROVISIONING_PROFILE_SPECIFIER` for Release/Profile is the
  literal placeholder `CI_PLACEHOLDER_PROVISIONING_PROFILE`; the `beta` lane
  patches it to the real profile name at build time and never commits that
  change back. For a one-off local archive, temporarily set the Release
  target's provisioning profile to your own in Xcode's Signing & Capabilities
  tab instead of relying on this value.
- **"No suitable application records were found"** — almost always a bundle
  ID typo, or the app doesn't exist yet in App Store Connect under that
  exact identifier. Double-check the bundle ID matches exactly (case
  included).
- **"The bundle version must be higher than the previously uploaded
  version"** — Apple requires each new build's `CFBundleVersion` (build
  number) to strictly increase for the same `CFBundleShortVersionString`
  (version name). The workflow passes `--build-number=$GITHUB_RUN_NUMBER`
  for this reason; if builds are ever uploaded manually instead, pass a
  higher build number explicitly.
- **CocoaPods/Xcode version drift** — if a build that works locally fails in
  CI (or vice versa), check `.github/workflows/ios-testflight.yml`'s pinned
  `runs-on` (macOS runner, which determines the Xcode version) against what's
  installed locally.
- **"version solving failed" on `flutter pub get`** — `pubspec.yaml`'s Dart
  SDK constraint (`^3.11.0`) is newer than the Dart SDK bundled with the
  Flutter version CI picked up. The workflow intentionally doesn't pin an
  exact `flutter-version` (it tracks the latest `stable` release via
  `subosito/flutter-action`) so this shouldn't happen on its own, but if the
  project's SDK constraint is ever bumped ahead of what's shipping on
  `stable`, this is the error you'll see.
- **"Failed to copy plugin ..." / `rsync: mkdir ... failed: No such file or
  directory` on `flutter pub get`** — macOS's bundled `rsync` (2.6.9) can't
  create missing parent directories, which breaks Flutter's Swift Package
  Manager plugin-copy step on a fresh checkout. The workflow runs
  `flutter config --no-enable-swift-package-manager` before `pub get` to
  avoid this, since plugins here are integrated via CocoaPods (`ios/Podfile`)
  anyway. If this resurfaces, check that step is still present and still
  runs before `pub get`.

## Reference

| Field | Value |
|---|---|
| App name | St Luke Parish App |
| Apple ID | `6821571661` |
| SKU | `st-luke-parish-app-ios-001` |
| Bundle ID | `au.org.stlukesmarsdenpark.parishapp` |
| Team | Catholic Parish of St Luke's Marsden Park |
| Team ID | `F5QH8M7RG6` |
| Workflow | `.github/workflows/ios-testflight.yml` |
| Fastlane lane | `ios/fastlane/Fastfile` → `beta` |
