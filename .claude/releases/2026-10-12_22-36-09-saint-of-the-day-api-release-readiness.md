# Release Readiness — 09-saint-of-the-day-api

- Branch: `feature/09-saint-of-the-day-api`, HEAD `81e180b` (verifier commit). It is 0 behind and 6 ahead of `origin/main` (`6ef2edd`), confirmed by `git fetch origin main` at the start of the deployer phase on 2026-10-13. The tree is clean.
- Verifier: PASS, user-approved 2026-10-12. Report: `.claude/verification/2026-10-12_22-36-09-saint-of-the-day-api.md`
- ADR: `.claude/decisions/0008-saint-of-the-day-from-parish-api.md` (supersedes ADR-0005)
- GitHub issue: none recorded for this feature.
- Remote: the branch is not pushed yet (`git ls-remote` returned nothing).

## What ships
- **Data source:** Saint of the Day loads from the parish API, `GET {API_BASE_URL}/v1/saints/{dateKey}`, where `dateKey` is the Sydney date computed on the device. The app no longer calls OpenRouter.
- **Removed:** the OpenRouter datasource, the free-text parser, the `OPENROUTER_API_KEY` dart-define and the prompt-date helper. `git grep -i "dart-define\|openrouter" -- . ':!.claude'` matches only the README line saying no `--dart-define` is needed.
- **Specific error messages, which resolves RISK-008.** There are six distinct messages:
  - not ready yet (503 `saint_not_ready`);
  - check your phone's date and time (404 `saint_not_available`);
  - temporarily unavailable (any other non-200, including 401 `app_check_required`);
  - no connection;
  - not set up (no `API_BASE_URL`);
  - something went wrong (parsing).
- **No visual change to the data view.** The error view now scrolls, so it reflows at large font sizes.
- **Unchanged:** the per-day on-device cache. Its storage format is the same (the diff to `saint_of_the_day_cache.dart` only changes comments).
- **Test infrastructure:** a repo-root `dart_test.yaml` adds a `live` tag, and the 3 real-network test files are tagged with it (RISK-007, partly mitigated).

## Configuration required for release
- **`OPENROUTER_API_KEY`: no longer needed.** No build command, CI step or fastlane lane needs a dart-define any more.
- **`assets/app.env` `API_BASE_URL=https://parish-app-service.fly.dev`:** already set and committed. `RELEASE_CHECK=true flutter test test/release_readiness_test.dart` passes the `API_BASE_URL` check (re-run this session).
- **`.github/workflows/ios-testflight.yml`: no change needed.**
  - It never passed `OPENROUTER_API_KEY`.
  - It already rewrites `assets/app.env` with `API_BASE_URL=https://parish-app-service.fly.dev` before building.
  - It also runs the release-readiness gate and a `.g.dart` drift check. Both pass on this branch's sources: the gate's `API_BASE_URL` check passes, and the verifier's clean `build_runner` rebuild produced no diff.
- **`ios/fastlane/Fastfile`: no change needed.** It runs `flutter build ipa --release` with no dart-defines.
- **Android build config: no change needed.** Nothing in `android/` passes defines. This branch touches no `android/`, `ios/`, `.github/`, `pubspec.yaml` or `pubspec.lock` files (`git diff --stat origin/main..HEAD`).

### Pre-existing item to resolve before any release build (not part of this feature)
- **The committed `assets/app.env` points `BASE_URL` at a local dev server.** It holds `BASE_URL=http://localhost:8080/tokens`, introduced by commit `c698c41` ("Updated the base url config to point to my local dev environment for testing", Michael Okolo, 2026-10-08). This feature does not modify it. `BASE_URL` is the push-token registration endpoint (`POST /tokens`).
- **What breaks if it ships:** push registration fails. `NotificationService` rejects non-https URLs in release mode, and even in debug a device can't reach `localhost` on the developer's machine.
- **The release check fails on it today** (re-run this session):

  ```
  assets/app.env BASE_URL is a release-ready https URL [E]
    Expected: 'https'  Actual: 'http'
  ```

- **iOS TestFlight via CI is not affected.** `ios-testflight.yml` overwrites `assets/app.env` with `BASE_URL=https://parish-app-service.fly.dev/tokens` before building.
- **Affected:** any local or manual release build, including every Android release build (there is no Android CI), unless `BASE_URL` is set to the production https URL first.
- **The user should decide:** either restore the committed default to production, or keep the local value and always fix it before a manual release build. Do not change it in this feature's PR.

## Probable production impact (stated as probable, not verified)
- **Saint of the Day probably never worked in store builds.** Feature 06 needed `--dart-define=OPENROUTER_API_KEY` at build time, and no CI or fastlane step ever passed it: the TestFlight workflow's `flutter build ipa` has no defines. So store and TestFlight binaries built that way probably showed "Saint of the Day isn't set up on this build yet."
- **This feature should fix that for users.** The screen now needs only `API_BASE_URL`, which CI already writes.
- **Not verified:** no store or TestFlight build was installed and inspected. The visualiser pass confirmed the fix on a debug emulator build with no dart-defines (Saint Wilfrid, October 12, served live).

## Validation (this session, HEAD `81e180b`, Windows)
| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 201 files, 0 changed, exit 0 |
| `flutter analyze` | No issues found, exit 0 |
| `flutter test` | **611 passed, 2 skipped, 0 failed**, exit 0. The 2 skips are the opt-in `RELEASE_CHECK` tests. The live saint test passed against production. |
| `flutter test --exclude-tags live` | **606 passed, 2 skipped, 0 failed**, exit 0. 611 - 606 = 5 live tests. |
| `flutter build apk --debug` | Built `build\app\outputs\flutter-apk\app-debug.apk`, exit 0 (Gradle 17.1s). There were only toolchain deprecation warnings: AGP 8.11.1 should go to 9.0.1 or later, and Kotlin 2.2.20 to 2.3.20 or later. Both are pre-existing and unrelated. |
| `RELEASE_CHECK=true flutter test test/release_readiness_test.dart` | `API_BASE_URL` passes. `BASE_URL` fails because it's `http://localhost`; this is pre-existing (see above). |
| iOS build | Not run, because this is a Windows machine. CI builds iOS through `ios-testflight.yml`. |
| `git status --porcelain` after all runs | Empty |

## Platform and permissions
- **Android:** no change. `INTERNET` was already granted (RISK-005, resolved). Pre-existing and not part of this feature: the `release` build type still signs with debug keys (`android/app/build.gradle` TODO), which matters before any Play Store upload.
- **iOS:** no ATS change, because the API is https.
- **Store listing:** no change. There are no new permissions, no new data collected and no new screens. Saint of the Day already exists, so no store-metadata note is needed. The device now sends only an anonymous `GET` with the date to the parish's own server, instead of a POST to a third-party AI service.

## Risks and open user decisions
- **RISK-019 (open, user decision, recommended before merge):** revoke or rotate the old OpenRouter key in the OpenRouter dashboard, or at least confirm a spend cap. Builds already distributed with the key can't be changed by this PR.
- **RISK-018 (open):** if parish_app_service switches App Check to `enforce`, Saint of the Day and Ministries break for every user. They would show "temporarily unavailable" until an App Check-capable build is widely installed. Coordinate with the server owner. The header hook is already in place.
- **RISK-007 (open, partly mitigated, user decision):** decide whether a plain `flutter test` should skip `live` tests by default before a CI pipeline runs the full suite. Today CI runs only `release_readiness_test.dart`, so nothing breaks now.
- **RISK-020 (low, optional):** a two-minute device check, not done yet:
  1. Turn on airplane mode, open Saint of the Day, and expect the network message with Try again.
  2. Set the largest system font and check both the error view and the data view.
  3. After a successful load, reopen the screen; it should be served from the cache, with no spinner.
- **RISK-017 (accepted):** the device clock picks the day.
- **Behaviour change:** the screen now depends on parish_app_service being up. Once a day is cached, it shows offline for the rest of that Sydney day. A first load during an outage shows "temporarily unavailable" or "no connection", with Try again. There is no bundled fallback (out of scope).
- **Upgrade note:** an install that cached an OpenRouter-generated entry today keeps showing it until the Sydney day rolls over, because the cache format and key are the same. This is harmless, and rare given that store builds probably had no key.

## Rollback
- **How:** revert the merge commit on `main`. No data migration is involved, and the cache format is unchanged in both directions.
- **What a rollback brings back:** the OpenRouter datasource and the `OPENROUTER_API_KEY` dart-define. A rolled-back build without the define shows "isn't set up". Once RISK-019's key revocation is done, a rolled-back build with the old key shows a generic connection error. So a rollback is only useful together with a new key passed at build time. The better recovery for a server-side problem is to fix parish_app_service; the app needs no new build for that.
- **No server-side rollback is needed.** The app only reads public `GET /v1/saints/{date}`.
