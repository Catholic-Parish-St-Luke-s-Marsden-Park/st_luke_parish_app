# Store Preparation Note — 01-bootstrap-app

- Feature ID: 01
- Feature Slug: bootstrap-app
- Branch: feature/01-bootstrap-app
- Timestamp: 2026-08-23_16-28
- Prepared by: DEPLOYER_AGENT

## Scope of This Note
This bootstrap-app feature is a UI shell only (theme, navigation, placeholder screens) — it does not include real feature content (bulletins, Mass times, contact info, etc.) and was never intended to be store-submission-ready on its own. This note records the current state of store-facing metadata/assets as of this feature, and what remains outstanding before any actual Google Play / Apple App Store submission, so nothing is silently assumed "done" later.

## Current State of Store-Facing Metadata

### App Identity
| Field | Android | iOS |
|---|---|---|
| Bundle/Application ID | `au.org.stlukesmarsdenpark.st_luke_parish_app` (`android/app/build.gradle.kts`) | `au.org.stlukesmarsdenpark.stLukeParishApp` (`ios/Runner.xcodeproj/project.pbxproj`) |
| Display name | `st_luke_parish_app` (`android:label` in `AndroidManifest.xml`) — **placeholder, package-name-style, not a human-facing display name** | `St Luke Parish App` (`CFBundleDisplayName` in `Info.plist`) — reasonable working title, not yet confirmed as the final parish-approved app name |
| Version | `1.0.0+1` (`pubspec.yaml`) — default initial version, appropriate for pre-release |

### App Icons
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` contains a full icon set (20x20 through 1024x1024) but these are Flutter's default template icons, not custom parish artwork.
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` — confirmed default Flutter template icon (e.g. `mipmap-xxxhdpi/ic_launcher.png` is 1,443 bytes, consistent with the stock Flutter logo asset, not a custom design).
- **Action required before submission:** replace with final parish-branded app icon (crest/logo per parish brand guidelines) on both platforms, regenerated via the standard Flutter icon tooling (e.g. `flutter_launcher_icons`) or manual asset replacement per platform icon size requirements.

### Screenshots / Store Listing Assets
- None exist in this repository (`.claude/store-metadata/` contained only a placeholder `README.md` before this phase). Not expected at this stage — the app currently shows only placeholder screens with no real content, so screenshots captured now would need to be recaptured once real feature content lands.

### Store Listing Copy (description, keywords, privacy policy URL, support URL, category)
- Not yet drafted. Out of scope for this bootstrap slice.

### Privacy / Data Safety Declarations
- Not yet assessed. Phase 1 is frontend-only, reading only public parish website content, with no user accounts, no analytics SDKs, and no data collection implemented so far in this feature — but a formal Data Safety (Play Console) / App Privacy (App Store Connect) declaration should be prepared once the feature set is closer to complete, not deferred indefinitely.

## Store Submission Readiness Verdict

**Not ready for app store submission** — and not expected to be, at this stage of the project. This is expected and appropriate for a bootstrap/shell-only feature; nothing here indicates a defect. The purpose of this note is to make the outstanding store-prep items explicit and trackable rather than discovered late:

1. Replace default Flutter app icons with final parish-branded icons (both platforms).
2. Confirm final human-facing Android display name (currently the raw package/project name, not a polished label).
3. Draft store listing copy, screenshots, and category once real feature content (bulletins, Mass times, contact info) exists to screenshot meaningfully.
4. Prepare privacy/data-safety declarations once data-handling behavior (even read-only scraping) is implemented and stable.
5. Run and verify `flutter build apk --release` / `flutter build appbundle` / `flutter build ios --release` at least once before any submission dry run (not yet done in this or any prior phase — only debug builds have been exercised).

None of the above block this PR or merge to `main` — they block store submission specifically, which is not being pursued at this feature's stage.
