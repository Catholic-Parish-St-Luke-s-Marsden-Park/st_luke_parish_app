# Manual iOS Build + TestFlight Upload

A step-by-step runbook for building and uploading an iOS release to
TestFlight **manually, from a local Mac**, as an alternative to the
`.github/workflows/ios-testflight.yml` CI pipeline. Useful when CI is broken
or unavailable — see `docs/app-store-connect-onboarding.md` for background on
App Store Connect, TestFlight, certificates and provisioning profiles, and
the one-time Apple Developer setup this depends on.

This path uses Xcode's **automatic signing** instead of the CI's manual
cert/profile import, since the signing identity, App ID, and Push
Notifications capability are already correctly configured on the Apple
Developer account (team `F5QH8M7RG6`) — Xcode can resolve all of that itself
once you're signed in with an account that has at least Admin/App
Manager/Developer role on the team.

## Prerequisites (one-time)

- Xcode → **Settings → Accounts** → your Apple ID is added and shows the
  **Catholic Parish of St Luke's Marsden Park** team.
- You have a role (Admin, App Manager, or Developer) on that team in App
  Store Connect / Apple Developer.

## Steps

### 1. Get the latest code

```bash
git checkout main
git pull origin main
```

If you want to cut a dedicated branch for this release rather than building
directly off `main`:

```bash
git checkout -b release
```

### 2. Bump the build number

Apple requires each new TestFlight upload's `CFBundleVersion` (the number
after `+` in `pubspec.yaml`'s `version:` field) to be **strictly higher than
the last one App Store Connect actually received** — not just higher than
what's currently in the file. Check **App Store Connect → your app →
TestFlight → iOS Builds** (or **Build Uploads**) for the highest number
already there, then edit `pubspec.yaml`:

```yaml
version: 1.0.0+<next-number>
```

### 3. Install dependencies

```bash
flutter pub get
cd ios
bundle exec pod install
```

Use `bundle exec pod`, not a system-installed `pod` — this project pins
CocoaPods via `ios/Gemfile`. The following warnings on `pod install` are
expected and harmless:

- `Automatically assigning platform iOS with version 15.0...`
- `CocoaPods did not set the base configuration...` (refers to the `profile`
  build configuration, not `Release` — doesn't block archiving)
- `FirebaseCore has been deprecated in favor of ... Swift Package Manager`

### 4. Open the workspace

```bash
open Runner.xcworkspace   # from inside ios/, or ios/Runner.xcworkspace from the project root
```

Must be the `.xcworkspace`, not `.xcodeproj` — CocoaPods requires the
workspace.

### 5. Switch Release signing to Automatic (local-only, never commit)

1. Project navigator → **Runner** project → **Runner** target →
   **Signing & Capabilities** tab.
2. Select the **Release** configuration tab.
3. Check **"Automatically manage signing"**.
4. Set **Team** to **Catholic Parish of St Luke's Marsden Park**.
5. Confirm the Status section resolves cleanly (no red errors). If you see
   `Communication with Apple failed` or `No profiles found`, click
   **Try Again** — this is usually a transient Apple API hiccup, not a real
   configuration problem, as long as:
   - The App ID `au.org.stlukesmarsdenpark.parishapp` exists under
     **Certificates, Identifiers & Profiles → Identifiers** on the Developer
     portal, with **Push Notifications** enabled, and
   - A **Distribution** certificate exists under **Certificates**.

   If retrying doesn't help, try removing and re-adding your Apple ID under
   Xcode → Settings → Accounts to refresh the session.

Do **not** commit this change — `ios/Runner.xcodeproj/project.pbxproj` is
normally committed with manual signing and a CI placeholder
(`CI_PLACEHOLDER_PROVISIONING_PROFILE`) for the GitHub Actions workflow.
After you're done, check `git status`/`git diff` on this file and revert it
if you don't intend to commit the automatic-signing switch.

### 6. Archive

1. Set the run destination (top toolbar) to **Any iOS Device (arm64)** —
   not a simulator.
2. **Product → Archive**. This is a full release build, so it takes a few
   minutes.
3. The **Organizer** window opens automatically when it finishes.

### 7. Pick the right archive and distribute

The Organizer's Archives list accumulates every archive you've ever made.
Sort by **Creation Date** and select the one you just built — the panel on
the right should show the **Version** matching what you set in step 2
(e.g. `1.0.0 (1001)`). Double-check this before distributing; picking an
older archive by mistake will re-upload a stale/duplicate build number and
Apple will reject it.

1. Click **Distribute App**.
2. **App Store Connect** → Next.
3. **Upload** → Next.
4. **Automatically manage signing** → Next.
5. Review the summary screen (defaults for bitcode/symbols are fine) → Next.
6. Xcode re-validates and signs → click **Upload**.
7. Wait for **"Uploaded to Apple"** (visible both in the Organizer and later
   in App Store Connect).

### 8. Export compliance (first upload of a new version, sometimes)

App Store Connect may prompt **"App Encryption Documentation"**. This app
only uses standard HTTPS (loading the public parish website and calling the
parish API's `GET /v1/*` / `POST /tokens` endpoints) — no custom or
proprietary encryption. Select:

> **"Standard encryption algorithms instead of, or in addition to, using or
> accessing the encryption within Apple's operating system"**

then **Save**.

To avoid this prompt on future uploads, add `ITSAppUsesNonExemptEncryption`
= `NO` to `ios/Runner/Info.plist` once.

### 9. Confirm

App Store Connect → your app → **TestFlight → iOS Builds**. The new build
number appears with status **Processing**, then becomes available to assign
to Internal/External testing groups after Apple finishes processing
(typically a few minutes, occasionally up to an hour).

## Troubleshooting

See `docs/app-store-connect-onboarding.md`'s **Troubleshooting** section for
signing/certificate/profile issues not covered above (bundle ID mismatches,
`.p12` export format problems, stale provisioning profiles, etc.) — those
apply to both the CI path and this manual path, since both ultimately rely
on the same Apple Developer account resources.
