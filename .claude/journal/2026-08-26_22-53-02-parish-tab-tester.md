# Journal — Tester Phase — 02-parish-tab

- Timestamp: 2026-08-26_22-53
- Branch: feature/02-parish-tab
- Phase: tester

## Summary
Independently verified the coder phase's implementation of feature 02-parish-tab against every acceptance criterion in the approved BA plan (REQ-F02-001 through REQ-F02-029, including REQ-F02-016a), by directly reading every changed/added `lib/` source file rather than trusting the coder's self-check, then authoring widget/unit tests deriving from each requirement.

Added 3 new test files and updated 1 existing test file:
- `test/features/parish/parish_screen_test.dart` (19 tests) — REQ-F02-001 through REQ-F02-011: hero copy, no-placeholder, 3-part Church Leadership section content/order/links (Pope Leo XIV / Bishop Vincent Long / Fr Gayan Thamel / Gerald "Ged" Oblea), no Deacon Tony Hoban, `AssetImage` (not `Image.network`) for all 4 leadership images, no icon row near About St Luke's, About St Luke's content present. Leadership-entry external-link taps verified via a fake `UrlLauncherService` injected through `ProviderScope.overrides`, avoiding real platform channels.
- `test/app/shell/app_bar_chrome_test.dart` (8 tests) — REQ-F02-014 through REQ-F02-019: wordmark logo via `Image.asset`, exactly 2 pills in `AppBar.actions`, no per-tab text title after the logo replaces it, Saint of the Day pill's placeholder dialog, Ask Luke pill's full-screen (not modal) navigation, and identical chrome across all 6 tabs.
- `test/features/ask_luke/ask_luke_screen_test.dart` (10 tests) — REQ-F02-020 through REQ-F02-028: header/subtitle/online indicator, welcome bubble before any chip tap, exactly 4 icon-free chips in exact order, each chip's exact hardcoded response (diffed verbatim against the BA plan's copy), no free-text input/send button anywhere, typed `List<AskLukeTopic>` config.
- `test/features/placeholder_screens_test.dart` (updated) — removed the `ParishScreen` case from the shared generic-placeholder table per the known pre-existing issue flagged by the coder; `ParishScreen` no longer belongs in a "still shows PlaceholderScreen" table since REQ-F02-001 deliberately replaced its content. The other 7 destinations (Masses, News, Ministries, Contact, Donate, Resources, Prayer Request) are unchanged and still assert their generic placeholder title/icon.

Full suite result: **58/58 passing, 0 failing** (up from the coder-phase baseline of 20 passing / 1 known-failing).

## Files Changed/Added
New:
- `test/features/parish/parish_screen_test.dart`
- `test/app/shell/app_bar_chrome_test.dart`
- `test/features/ask_luke/ask_luke_screen_test.dart`

Modified:
- `test/features/placeholder_screens_test.dart` (removed `ParishScreen` case + updated doc comment / "distinct titles" count from 8 to 7)

No `lib/` files were modified in this phase.

## Commands Run and Results
- `flutter test` (baseline) — 20 passing, 1 failing (`ParishScreen` case in `placeholder_screens_test.dart`), matching the coder journal's reported state exactly before any Tester changes.
- `flutter test test/features/parish/parish_screen_test.dart` — 19/19 passing (after 2 test-authoring fixes; see below).
- `flutter test test/app/shell/app_bar_chrome_test.dart` — 8/8 passing.
- `flutter test test/features/ask_luke/ask_luke_screen_test.dart` — 10/10 passing.
- `dart format .` — reformatted the 3 new test files.
- `dart format --output=none --set-exit-if-changed .` — exit 0 (clean).
- `flutter analyze` — "No issues found!"
- `flutter test` (full suite, final) — 58/58 passing, 0 failing.
- `git status --short` — confirmed only test files were touched; no `lib/` changes made by Tester; the 5 out-of-scope tab screens remain untouched (REQ-F02-012).

## Test-Authoring Fixes (test files only, no production code touched)
1. Leadership-entry taps (Bishop Vincent Long, Fr Gayan Thamel, Ged Oblea) initially failed to hit-test because those rows render below the default `800x600` test viewport inside `ParishScreen`'s `ListView`. Fixed with `tester.ensureVisible(...)` + an extra `pumpAndSettle()` before each tap — a test-technique fix, not an app bug.
2. `find.text('Church Leadership')` initially found nothing because `SectionLabel` renders `label.toUpperCase()`; corrected the assertion to the actual rendered `"CHURCH LEADERSHIP"` text after confirming this is `SectionLabel`'s intentional, existing behavior (read `section_label.dart` to confirm, not guessed).

## Architecture/Standards Compliance
- Tests follow the existing repo convention: feature-first test file locations under `test/features/<feature>/` and `test/app/shell/`, mirroring `lib/`'s structure.
- `UrlLauncherService` overridden via Riverpod `ProviderScope.overrides` per the coder's own design intent (documented in the coder plan) — no platform-channel mocking hacks needed.
- No implementation code changed to force tests to pass; the two fixes above were confined to test files and are explained above, consistent with the "small, obviously-correct" bar for tester-initiated changes (per the coder-agent's own `Material`-ancestor-fix precedent) — though in this case both fixes were purely within the new test files, not `lib/`.

## Unresolved Coverage Gaps (see tester plan for full detail)
1. REQ-F02-015 (chrome location) verified as a source/import-path check, not a runtime widget-tree assertion — different verification method than other REQs, not a coverage weakness in effect.
2. No live device/emulator run in this session — AppBar width pressure on real narrow phones (logo + 2 pills + hamburger) not independently confirmed beyond "no Flutter overflow exception in the default test viewport."
3. Image asset quality/licensing not testable via `flutter test` — carried forward from the coder plan, still open and non-blocking.
4. Real `url_launcher` platform-channel behavior (actual external browser launch on Android/iOS) is not exercised by any test in this repo, by design (fakes are injected to avoid platform channels) — a manual on-device tap-through is the appropriate follow-up, not a Tester-phase blocker.
5. No golden/visual regression tests added — consistent with the same judgment call made in `01-bootstrap-app`'s tester phase (UI still expected to evolve).

## Handoff
- Next phase: VERIFIER_AGENT, only after user approval
- Stopping here; awaiting user review of the tester plan, the new/updated test files, and this journal entry
