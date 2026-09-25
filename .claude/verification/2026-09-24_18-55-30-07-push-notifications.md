# Verification Report — 07-push-notifications (retrospective)

- Branch: `feature/07-push-notifications`
- Author head before fixes: `089082e`
- Review-fix commits: `35f9dbd` (server/iOS delivery), `3a2ae3a` (format), `41284aa` (drop Crashlytics and tap routing), `794a46f` (package upgrades), `7ae7445` (tests), `59edd6a` (nits)
- Verifier session: 2026-09-24_18-55

## Command re-run (this machine, head `59edd6a`)

| Command | Result |
|---|---|
| `dart format -o none --set-exit-if-changed $(git ls-files '*.dart')` | Clean: 145 files, 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | **304 passed, 1 skipped** (the skip is `release_readiness_test.dart`, which runs only with `RELEASE_CHECK=true`), 0 failed |
| `cd server && npm test` | 13 passed, 0 failed |
| `flutter build ios --no-codesign --debug` | Built. All plugins resolve as Swift Packages, and `ios/Podfile.lock` is unchanged |
| `flutter build apk --debug` | **Not run.** There's no Android SDK on this machine |

Before the fixes, `flutter test` on `089082e` had **4 failures**: every `postToken` test threw `core/no-app` because `FirebaseMessaging.instance` was read when the object was constructed. `7ae7445` fixes this.

## Traceability Matrix — REQ-F07-001..018

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| 001 Android once per push | `server/app.js:55-66` (no `notification`, `android.priority: high`); `background_handler.dart:12`; `notification_service.dart:179` (foreground local show) | `server/test/app.test.js` "sends Android data-only at high priority…" | ✅ code + test. **Device re-check needed after upgrade** |
| 002 iOS visible | `server/app.js:61-65` (`apns.payload.aps.alert`); iOS foreground presentation options in `_setupListeners` | same server test (asserts the alert and sound) | ⚠️ code + test; **on-device unverified (RISK-009)** |
| 003 Channel and sound | `notification_helpers.dart:88` `createChannel`; `notification_service.dart:135` | — (a platform call; no unit seam) | ⚠️ code only |
| 004 32-bit IDs | `notification_helpers.dart:17,19` | `notification_helpers_test.dart` `generateId` group (3 tests) | ✅ |
| 005 runApp always runs | `main.dart:17,25,37` each wrapped in try; `runApp` at `:46`; `setup()` un-awaited with `catchError` | — (the `main()` bootstrap isn't unit-testable without plugin fakes) | ⚠️ code only |
| 006 BASE_URL validation | `notification_service.dart:62` `resolveBackendUri`; `_backendUri` guards an unloaded dotenv | `resolveBackendUri` group (6 tests); `sendTokenIfChanged` "missing", "never loaded", "non-https in release" | ✅ |
| 007 Retry, give up, no cache on failure | `notification_service.dart:273` `postToken`; the `sendTokenIfChanged` else branch | `postToken` group (4); "does not cache a failed registration…" | ✅ |
| 008 `token@origin` cache | `notification_service.dart:247` | `sendTokenIfChanged` group: first send, unchanged skip, new token, new origin | ✅ |
| 009 Token refresh | `notification_service.dart:229` with `catchError` | — (the listener needs FCM) | ⚠️ code only |
| 010 aps-environment | `ios/Flutter/Debug.xcconfig:5`, `Release.xcconfig:6`, `Runner.entitlements:6`; Profile uses Release.xcconfig | iOS build succeeded | ⚠️ build only; TestFlight unverified (RISK-009) |
| 011 Android manifest | `AndroidManifest.xml:6,43` | — | ✅ by inspection |
| 012 SwiftPM pins | `ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved`, `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` | iOS build; no Podfile.lock drift | ✅ |
| 013 `/tokens` | `server/app.js:134` plus the rate limiter at `:112` | "stores a valid token…", "rejects a missing or malformed token" | ✅ (the rate limit itself isn't tested) |
| 014 API key and validation | `server/app.js:103` (timing-safe), `:38` `isValidData`, `:161`, `:193` | `/send` and `/broadcast` key tests; title, body and non-object `data` rejects | ✅ |
| 015 Batching and pruning | `server/app.js:121`, `/broadcast` loop | "batches by 500 and prunes stale tokens"; "prunes a stale token and returns 404" | ✅ |
| 016 Server tests | `server/package.json` `"test": "node --test"`; `server/test/app.test.js` | 13 passing | ✅ |
| 017 Quality gates and latest packages | `pubspec.yaml` (firebase_core 4.15.0, firebase_messaging 16.7.0, flutter_local_notifications 22.3.1, flutter_dotenv 6.0.1); `server/package.json` (firebase-admin 14.5.0, dotenv 18.0.3) | command table above | ✅ |
| 018 Release check | `test/release_readiness_test.dart` | runs with `RELEASE_CHECK=true` | ✅ (opt-in by design) |

## Gaps (not blocking the fixes, logged as risks)
- **RISK-009**: iOS delivery and the Release `aps-environment` can't be verified until a developer account and a device are available. The Android runtime needs a device re-check after the flutter_local_notifications 17 → 22 and firebase_messaging 15 → 16 upgrades.
- **RISK-010**: `/tokens` is unauthenticated, so anyone can write syntactically valid tokens; mitigated only by the per-IP rate limit. Also, two moderate `uuid` advisories come through firebase-admin's transitive `gaxios`, which `npm audit fix` can't resolve.
- **RISK-011**: Firebase/Firestore and a Node server were chosen over the Supabase that CLAUDE.md anticipated for Phase 2, and `NotificationService` is a global singleton outside Riverpod.

## Verdict
**Conditional pass.** Every requirement has code evidence, and every requirement with a pure unit seam has test evidence. The conditions are the manual device checks in RISK-009.
