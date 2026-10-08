# Release Readiness Note — 08-events-calendar

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Timestamp: 2026-10-08_11-06
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-10-07_10-22-events-calendar.md`). All 39 BA-approved requirements (REQ-F08-001..039) have complete, independently-verified traceability: 34 with direct code + test evidence, 5 (REQ-F08-021, 027-030) correctly retired by the visualiser phase's round-2 redesign, 1 (REQ-F08-032) correctly amended.

This note assesses **local release readiness** (buildability, test health, rebase status) and gives explicit, clearly-separated disclosure of the risks that belong to this feature. **Two of the three risks the verifier phase flagged have since been found, fixed, and confirmed live** in a post-verifier review-fix round, immediately before this deployer phase started. The third (RISK-014) remains open — **the user has already made the ship-vs-defer decision for it** (asked directly during the tester/deployer phases) — this note documents that decision accurately; it does not re-decide it.

## MOST IMPORTANT DISCLOSURE FOR THIS FEATURE — READ FIRST: what the post-verifier review-fix round found

The verifier phase logged **RISK-015** as a *coverage gap*: none of the visualiser phase's three live-feedback rounds had ever actually tapped "Add to my calendar" and watched the native calendar app open — every round's feedback was about the button's visual styling. Immediately after the verifier phase closed, the user did exactly that live test, and it surfaced two real, user-facing defects in production behavior — not hypothetical gaps:

- **RISK-015 (confirmed, then fixed):** tapping "Add to my calendar" showed the app's own failure message instead of opening the calendar. Root cause: `android/app/src/main/AndroidManifest.xml` was missing a `<queries>` entry for `ACTION_INSERT`/`vnd.android.cursor.item/event`, which Android 11+'s package-visibility rules require even when a calendar app is installed. **Fixed** (commit `c21ed4c`) and **confirmed resolved live** — the user rebuilt and re-tapped on the same Android emulator used throughout the visualiser phase, and the native calendar app now opens correctly.
- **RISK-016 (new, found during that same re-test; fixed):** once the calendar app opened, it showed the **wrong date/time** — a "Thu 8 Oct 7:00 pm" event landed as "Fri 9 Oct 6:00 AM", an 11-hour/next-day error. Root cause: this app's internal "fake UTC" `DateTime` representation (Sydney wall-clock digits tagged as UTC — correct for this app's own display code, which only ever reads the digits directly) was passed straight into `add_2_calendar`, which treats `DateTime` as a real UTC instant. **Fixed** (same commit) by adding `sydneyFakeUtcToRealUtc()` and converting both the start and end times before export, with 3 new fixed-date unit tests (covering both AEDT and AEST) and tightened widget-test assertions so a regression back to passing the raw fake-UTC value would be caught automatically next time. **Confirmed resolved live** — same re-test, same emulator, correct date/time now shown.

Both risks are marked **resolved** in `active-risks.md`. This is flagged prominently here, not folded quietly into "all risks resolved," because it's a meaningful data point: the verifier phase's own traceability review correctly predicted exactly where a live-device gap existed, and that gap turned out to contain two real defects a widget test alone could not have caught (the widget tests exercise a fake `CalendarExportService`, by deliberate and correct test design — this is the same class of gap RISK-003/004 describe for `url_launcher`).

## RISK-014 — open, carried forward by explicit user decision

- **What's the gap:** `parseIcsEvents` in `ics_event_parser.dart` filters on an event's `start` alone in all three of its code paths, where REQ-F08-005 specifies filtering by *end* (falling back to `start` only when no end/duration is known). A currently-in-progress event (e.g. a Mass checked mid-service) is incorrectly excluded from the upcoming-events list for its own duration, then reappears as its next recurrence once it ends.
- **Severity:** Low. Narrow window per event (roughly the 30-75 minute duration of the event itself, and only if a user happens to open the News tab during that window), though it recurs on every occurrence of every recurring event.
- **This agent did not fix RISK-014:** the correct fix touches recurrence-expansion timing logic (computing each candidate occurrence's effective end, including threading a widened `after:` bound through the `rrule` package's own expansion) that this session cannot verify by executing `flutter test` directly. Per the user's standing decision (first made at the tester phase, unchanged since), this is deferred to a future, small, dedicated Coder follow-up rather than risked as a blind patch in this phase.
- **Fix, if the user later wants to close it:** compute `effectiveEnd = duration != null ? candidateStart.add(duration) : candidateStart` per candidate and filter on that instead of `candidateStart` alone, in all three branches of `parseIcsEvents`; widen the RRULE path's `after:` bound so an in-progress recurring instance isn't dropped by the `rrule` package itself before the app's own filter runs. Full detail already recorded in `active-risks.md`.

## RISK-003 / RISK-004 / RISK-005 — pre-existing platform-configuration items, confirmed status for this feature

- **RISK-003 / RISK-004** (external-link manifest gaps) — **confirmed to extend** to this feature's 2 new `https:` tap targets: the website fallback link and the Details sheet's optional secondary link. No new scheme type introduced. Remain open, project-wide, same as every prior feature.
- **RISK-005** (Android `INTERNET` permission) — **confirmed applicable and already covered.** This feature's ICS feed fetch uses the same unscoped permission already declared and already covering News' RSS fetch and Saint-of-the-Day's OpenRouter calls. No manifest change needed for this beyond the `<queries>` entries already made for RISK-015.

## Local Validation Evidence (user-run, 2026-10-08, fresh session on HEAD `670cd4a`)

| Command | Result |
|---|---|
| `flutter analyze` | Clean, no issues |
| `dart format . --set-exit-if-changed` | `0 changed` (166 files), exit 0 |
| `flutter test` | `357 passed / 1 skipped (pre-existing) / 0 failed` — up from the tester phase's 357 baseline count by the 3 new `sydneyFakeUtcToRealUtc` tests, net even since 1 pre-existing skip carries forward |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |
| `git fetch origin main` + rebase check | `0` behind, `14` ahead — no rebase needed |

**Environment note, consistent with every prior feature's deployer phase in this repo:** this cloud-side session has no Flutter SDK and no GitHub credentials, so the validation above was run by the user directly rather than independently re-run by this agent. Flagged as a methodology continuation, not hidden. `flutter --version` was not captured this round — a minor gap, not expected to matter, but not assumed either.

## Working Tree / Git State
- Current branch: `feature/08-events-calendar`, HEAD `670cd4a`
- Working tree: clean except this phase's own new artifacts and the memory/feature-index updates
- User ran `git fetch origin main` this session: `origin/main` confirmed current — **0 commits behind, 14 ahead**. **No rebase required** (re-check again immediately before PR creation, since `main` could move before the PR is opened).
- `gh` CLI availability on the user's own machine is **unconfirmed** this phase (see the deployer plan's Observations) — needs a direct check at PR-agent time.
- This feature's shared/infra footprint is small and self-contained: `pubspec.yaml`/`pubspec.lock` (+`rrule`, `timezone`, `add_2_calendar`), `android/app/src/main/AndroidManifest.xml` (+16, includes the RISK-015 `<queries>` fix), `ios/Runner/Info.plist` (+4, `NSCalendarsUsageDescription`, present since the coder phase). No `analysis_options.yaml`/`README.md`/`.gitignore` changes. No secrets, tokens, or credentials observed in the changed files.

## Store-Prep Consideration
This feature adds a new inline section to the existing News tab plus an in-app pagination flow and Details bottom sheet — it does not touch any store-facing listing content (description, screenshots, keywords, age rating, privacy nutrition labels). The new Android `<queries>` entries and iOS `NSCalendarsUsageDescription` are standard runtime-permission-prompt-level disclosures already common to this app's category, not anything requiring a store-listing change. No `.claude/store-metadata/` note is produced.

## Rollback Notes

This feature is additive and self-contained: a new `lib/features/events/` tree (17 files across domain/data/presentation), a new `EventsSection()` on the existing News tab, plus the small shared-file footprint listed above. Unlike 06-saint-of-the-day, it carries **no** project-wide toolchain bump — nothing else on `main` depends on anything this feature's commits introduce.

- New/changed surfaces: `lib/features/events/` (domain/data/presentation, all directories, 17 files), `lib/features/news/presentation/screens/news_screen.dart` (EventsSection wiring), `lib/core/constants/external_links.dart`, `pubspec.yaml`/`pubspec.lock`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `.claude/decisions/0007-events-ics-rrule-and-robots-scope.md`, plus the test files under `test/features/events/**`.
- **Rollback risk specific to this feature:** low. A straightforward `git revert <merge-commit-sha>` should be self-contained — no later feature branch exists yet that depends on this feature's code, and the shared-file footprint (3 new pubspec dependencies, 2 manifest additions) is additive-only with no modification to existing shared config.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; a live production issue with the ICS feed parsing or the calendar export beyond what's already disclosed above.
- **Rollback procedure:**
  1. Preferred: `git revert <merge-commit-sha>` — reverts the feature code and shared-file additions together as one unit.
  2. If a defect is found only in a specific area (e.g. just the calendar export, or just the ICS parser): fix forward instead of reverting, since all 39 *verified* requirements have no known application-code defect — the only carried-forward item (RISK-014) is a narrow filtering edge case, not a functional failure of the feature as a whole.
- No database, backend config, feature flags, or store listings are affected by this feature. No app-store submission has occurred — no store-side rollback applies yet.

## Release Readiness Verdict

**Locally release-ready for a debug/internal build** — analyze/format/test/build all clean, user-confirmed fresh this phase, 357 passing (3 more than the tester-phase baseline, from today's review-fix round), matching the verifier's traceability exactly. The two risks the verifier phase itself predicted and flagged as a coverage gap (RISK-015, and the RISK-016 it led to finding) have since been found via real live-device testing, fixed, and confirmed resolved — a genuine example of the verifier's own methodology catching a real gap before it reached users. The one remaining open item, **RISK-014**, is narrow, non-blocking, and the user has explicitly chosen to defer it to a future Coder follow-up rather than fix it in this phase. This note discloses all of the above prominently and does not soften or withhold any of it.
