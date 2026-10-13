# Journal — Tester Phase — 09-saint-of-the-day-api

- Timestamp: 2026-10-12_23-25
- Branch: `feature/09-saint-of-the-day-api`. Started from clean HEAD `c9e1373`, which is rebased on origin/main `6ef2edd`.
- Plan: `.claude/plans/tester/2026-10-12_22-36-09-saint-of-the-day-api.md`. It holds the full traceability table.

## Test summary
- **+48 tests.** `flutter test` went from 563 to **611 passed, 2 skipped** (the opt-in release checks), with 0 failed.
- **Every REQ-F09-001..023 traces to at least one test or static check.** No REQ is uncovered.
- **New file:** `test/features/saint_of_the_day/data/repositories/saint_of_the_day_repository_integration_test.dart` (15 tests). It runs the repository with the real datasource on a MockClient, the real shared_preferences cache, and the clock built as `sydneyNow(fixedUtc)`. It checks:
  - cache hit, miss and corrupt entries;
  - that 8 failure kinds leave the stored prefs byte-for-byte unchanged;
  - that a throwing write doesn't fail the read;
  - the AEDT midnight rollover;
  - what happens when the server dateKey doesn't match the requested key.
- **Extended files:**
  - datasource tests (+14): exact default header set, status and code cross-checks, malformed or non-UTF-8 problem bodies, trailing-slash base;
  - parser tests (+9);
  - sydney_date tests (+3): DST years where the 1st of the month is a Sunday, and the leap day;
  - screen tests (+4): server displayDate, empty saying with a full saint, Try again re-runs the load, non-failure error;
  - provider tests (+3): no App Check header through the real wiring, reload hits the cache, invalid API_BASE_URL gives NotConfigured.
- **Live tests:** added `dart_test.yaml` with a `live` tag, and tagged all 3 real-network test files: bulletins, events and saint.
  - A plain `flutter test` still runs them.
  - `--exclude-tags live` gives 606 passed / 2 skipped.
  - `--tags live` gives 5 passed.
  - RISK-007 is updated to "open, partly mitigated".

## Commands
- `dart format .`: 0 changed (201 files).
- `flutter analyze`: no issues.
- `flutter test`: 611 passed / 2 skipped / 0 failed.
- `flutter test --exclude-tags live`: 606 / 2 / 0.
- `flutter test --tags live`: 5 passed.
- Saint live test alone: 1 passed (production returned 200).
- `build_runner build`: no diff in `lib/`.
- `grep -rli openrouter lib test README.md`: no matches.

## Failing cases
- One failure, in my own new retry widget test. The shared pump helper lacks the app's `retry: noAutomaticRetry`, so Riverpod's automatic retry succeeded before the error view showed. I fixed the test by using the app's retry policy. This was not a product defect.

## Defects
- None. No lib code was changed.

## Unresolved gaps
- The `developer.log` line (REQ-F09-007) is not captured in tests.
- There are no golden tests.
- The failure-state text-scale sweep runs on the smallest phone only.
- A plain offline `flutter test` still fails on the live tests.

## Stopping point
- Not committed. Awaiting user approval before VISUALISER_AGENT.
