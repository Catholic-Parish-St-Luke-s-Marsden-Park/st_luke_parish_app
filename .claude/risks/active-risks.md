# Active Risks

Log active technical, scraping, or delivery risks here. Add one entry per risk; move resolved risks to a "Resolved" section instead of deleting them.

## Template

- **Risk ID:** RISK-XXX
- **Title:**
- **Feature:** (feature ID/slug this risk relates to, if any)
- **Impact:**
- **Likelihood:**
- **Mitigation:**
- **Owner:**
- **Status:** open / mitigated / accepted / closed

## Open Risks

- **Risk ID:** RISK-003
- **Title:** Leadership-entry external links (Pope Leo XIV, Bishop Vincent Long, Fr Gayan Thamel) silently fail to launch on real Android devices — missing AndroidManifest `<queries>` block
- **Feature:** 02-parish-tab
- **Impact:** High for user-facing correctness of REQ-F02-005/006/007. Tapping any of the 3 tappable Church Leadership entries produces no visible effect on a real Android device/emulator (confirmed live on `emulator-5554`, API 36) even though the corresponding widget tests pass. Root cause: `android/app/src/main/AndroidManifest.xml` has no `<queries>` entry for a browsable `http`/`https` `VIEW` intent, so on Android 11+ (API 30+) package-visibility rules cause `url_launcher`'s `canLaunchUrl` (called at `lib/core/services/url_launcher_service.dart:24`) to return `false` for every browser package, and `launchExternal` silently returns `false` without ever calling `launchUrl` — no exception, no crash, no visible feedback to the user. Widget-test evidence for REQ-F02-005/006/007 (`test/features/parish/parish_screen_test.dart`) cannot catch this by design, since those tests inject a fake `UrlLauncherService` via `urlLauncherServiceProvider.overrideWithValue(...)` specifically to avoid touching platform channels — a reasonable test-design choice that nonetheless leaves this exact class of platform-configuration bug undetectable by any current automated test.
- **Likelihood:** Certain — already reproduced live (before/after screenshots identical, `adb logcat` shows no exception around the tap).
- **Mitigation:** Add a browsable-intent `<queries>` block to `android/app/src/main/AndroidManifest.xml` (an `<intent>` with `android.intent.action.VIEW`, category `android.intent.category.BROWSABLE`, and `<data android:scheme="https"/>`), then re-verify live on an Android emulator/device that all 3 leadership-link taps (Pope Leo XIV, Bishop Vincent Long, Fr Gayan Thamel) open an external browser. Tracked as GitHub issue #12 (https://github.com/Catholic-Parish-St-Luke-s-Marsden-Park/st_luke_parish_app/issues/12), filed by the App-Visualiser phase with root cause and suggested fix included. This is a manifest-only fix; no `lib/`/`test/` code changes are required.
- **Owner:** Deployer (or a targeted Coder follow-up before merge, at the user's discretion)
- **Status:** open

- **Risk ID:** RISK-004
- **Title:** iOS external-link launching for the same 3 leadership entries is unverified — `Info.plist` has no `LSApplicationQueriesSchemes` entry and no iOS simulator/device run has been performed for this feature
- **Feature:** 02-parish-tab
- **Impact:** Medium. Confirmed via direct read of `ios/Runner/Info.plist` (this phase) that no `LSApplicationQueriesSchemes` key exists. `https` is a standard system URL scheme that `canLaunchUrl`/`url_launcher` typically does not require an `LSApplicationQueriesSchemes` entry for on iOS (unlike custom app schemes), so this may already be fine — but this has not been positively confirmed by running the app on an iOS simulator/device, and the Android-side RISK-003 demonstrates this exact class of platform package-visibility/query-declaration gap is a real, live risk category for this dependency, not merely theoretical.
- **Likelihood:** Low-medium — plausible given RISK-003's precedent for the same dependency, but unconfirmed either way.
- **Mitigation:** Run the app on an iOS simulator/device and tap all 3 leadership entries to confirm the external browser opens; if a gap is found, add the required `LSApplicationQueriesSchemes` entries to `ios/Runner/Info.plist`. Recommended before or during the Deployer phase's iOS build/release-readiness work.
- **Owner:** Deployer
- **Status:** open

## Resolved Risks

- **Risk ID:** RISK-002
- **Title:** REQ-F01-001 (themed shell) and REQ-F01-006 (no overflow/clipping) are not fully end-to-end verified
- **Feature:** 01-bootstrap-app
- **Impact:** Low-medium for this bootstrap slice; would grow if left unaddressed as real feature content lands. Android build succeeded (confirmed by verifier) but had not been run/visually confirmed on an Android emulator or device by any phase. Separately, the REQ-F01-006 overflow/clipping test suite only catches Flutter's exception-raising layout failures (`RenderFlex overflowed`, etc.) — silent visual clipping that fits within bounds without throwing an exception would not be caught, since no golden-image tests exist yet.
- **Likelihood:** Was medium — shell-only slice has low visual complexity today, but risk would grow as real feature screens replace placeholders.
- **Mitigation:** 2026-08-23: Booted Android emulator `Medium_Phone_API_36.1` (API 36), installed debug APK, launched the app live via `adb`/`monkey`. Confirmed: Parish home screen renders with themed shell (navy/gold, church icon, serif title); tapping the "Masses" bottom-nav tab correctly switches app bar title/icon/content to "Masses & Events" and highlights the active tab; the navigation drawer opens showing "St Luke's Parish" header plus Resources/Prayer Request entries. `adb logcat -d "*:E"` showed no Flutter/app errors or crashes during the session — only unrelated Play Store (Finsky) noise. This closes the Android live-run visual-verification gap. Golden-image tests remain intentionally deferred until placeholder screens are replaced by stabilized real feature UI (per root `CLAUDE.md`'s "stable, important UI states" guidance and the BA/coder plans' own note that placeholders will be reworked) — tracked as follow-up work for the next feature slice, not a residual risk on this one.
- **Owner:** Deployer (verified 2026-08-23); Tester/Coder for the next feature slice owns golden-test follow-up
- **Status:** resolved (Android live-run verified 2026-08-23; golden-test follow-up deferred by design, not a blocking risk)

- **Risk ID:** RISK-001
- **Title:** Orchestrator `complete-phase` step is not committing implementation/test code across phase transitions
- **Feature:** 01-bootstrap-app
- **Impact:** High for auditability/traceability. Across the ba -> coder -> tester -> verifier phase transitions on `feature/01-bootstrap-app`, only `.claude/plans .claude/journal .claude/verification .claude/memory.md` had been committed at each phase-close (commits `92b5c27`, `09bf292`, `d18bcb0` were docs/feat/test commits containing plan+journal artifacts only, despite messages implying code landed). The actual application source (`lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `android/`, `ios/`, `.metadata`, `.gitignore`, `analysis_options.yaml`) had never been committed and remained untracked in the working tree, confirmed via `git status` as of the verifier phase (2026-08-23_16-10).
- **Likelihood:** Was certain (already occurred); would have recurred on every future feature without the fix.
- **Mitigation:** Fixed 2026-08-23: backfilled the missing implementation/test code in commit `ac86f4c`, and patched `agent_orchestrator.sh`'s `complete_phase()` to `git add -A` (staging the full working tree, not just `.claude/` bookkeeping) plus added a dirty-working-tree guard to `prepare_pr()` so it refuses to rebase over uncommitted work.
- **Owner:** Orchestrator/process owner
- **Status:** resolved (user-directed fix, 2026-08-23)
