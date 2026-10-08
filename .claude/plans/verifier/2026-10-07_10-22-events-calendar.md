# VERIFIER_AGENT Plan

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Phase: verifier
- Timestamp: 2026-10-07_10-22

## Inputs
- Approved BA plan: `.claude/plans/ba/2026-10-01_11-15-09-events-calendar.md` (REQ-F08-001..039)
- Coder plan: `.claude/plans/coder/2026-10-01_11-15-09-events-calendar.md`
- Tester plan: `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`
- Visualiser plan/journal: `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md`, `.claude/journal/2026-10-01_12-58-events-calendar-visualiser.md` (3 live-feedback rounds plus a round-2.5 tweak pass, all committed, closed `2026-10-07` with the user's final "yes")
- Root `CLAUDE.md`, `.claude/memory.md`, `.claude/risks/active-risks.md`
- All 17 `lib/features/events/**` source files (domain/data/presentation, all directories) plus the News-tab wiring (`lib/features/news/presentation/screens/news_screen.dart`) and `lib/core/constants/external_links.dart` — read directly this session, file by file, not taken on the coder/tester/visualiser plans' self-reports
- All 4 `test/features/events/**` test files (the former `all_events_screen_test.dart` was deleted during the visualiser phase's round-2 redesign, confirmed via `git log`/`grep`) — read directly this session
- `.claude/decisions/0007-events-ics-rrule-and-robots-scope.md`, `pubspec.yaml`/`pubspec.lock` (dependency check), `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
- Precedent format: `.claude/plans/verifier/2026-09-10_08-52-06-saint-of-the-day.md`, `.claude/verification/2026-09-10_08-52-06-saint-of-the-day.md`, `.claude/journal/2026-09-10_08-52-06-saint-of-the-day-verifier.md`

## Method
1. Read every approved-phase artifact in full (BA, coder, tester, visualiser plans + journals), plus `.claude/memory.md`'s Latest Session Logs, giving particular attention to the visualiser phase's three live-feedback rounds and its documented, user-authorized deviation from the default no-rework-loop/file-as-issue procedure.
2. Independently read every `lib/features/events/**` implementation file (domain entity/failures/repository contract; data datasource/parser/repository; presentation providers/services/utils/widgets, including the generated `.g.dart`), the News-tab wiring, and all 4 corresponding test files — not relying on the coder/tester/visualiser plans' self-reports.
3. Built a full requirement -> code evidence (file:line) -> test evidence traceability matrix for all 39 REQ-F08-001..039, explicitly marking the ones the visualiser phase retired (`REQ-F08-021`, `REQ-F08-027..030`) or amended (`REQ-F08-032`) rather than silently dropping them from the matrix.
4. **Environment constraint, flagged rather than hidden**: this session has no Flutter SDK reachable, same as the 06/07 verifier phases before it. Re-stated the user's own most recent confirmed clean re-run (visualiser round 3 gate, 2026-10-01: `flutter analyze` clean, `dart format` clean, `flutter test` 354 passed/1 skipped/0 failed) instead of an independent re-run, and recommended one more fresh pass immediately before Deployer/PR.
5. Checked RISK-003/RISK-004/RISK-005 applicability by grepping `lib/features/events/` for `url_launcher`/`UrlLauncher`/`webview_flutter`/`tel:`/`mailto:`, and by re-reading `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` directly.
6. Independently assessed the visualiser-phase evidence across all three rounds (genuine live-Android hands-on feedback, correctly actioned each time) and identified one gap it did not cover: no round ever confirmed, on a real device/emulator, that tapping "Add to my calendar" actually opens the native calendar app pre-filled with the event (REQ-F08-024's core behavior) — every round's feedback was about the button's visual styling only, and REQ-F08-024/025 are otherwise verified solely against a fake `CalendarExportService` in widget tests. Logged as new **RISK-015**.
7. Re-confirmed RISK-014 (carried forward from the Tester phase, open) still accurately describes the current `ics_event_parser.dart` by re-reading the file directly this session.

## Scope
Read-only over `lib/`/`test/`/`android/`/`ios/` — no implementation or test code modified in this phase.

## Outputs
- This verifier plan
- Verification report: `.claude/verification/2026-10-07_10-22-events-calendar.md`
- New risk logged in `.claude/risks/active-risks.md`: RISK-015 (no live-device confirmation that "Add to my calendar" opens the native calendar app)
- RISK-014 re-confirmed as still accurate and open (no addendum needed, already correctly scoped)
- Confirmed RISK-003/RISK-004 extend to this feature's 2 new `https:` external-link tap targets (website fallback link, Details sheet's optional secondary link); confirmed RISK-005's existing unscoped `INTERNET` permission already covers this feature's feed fetch

## Handoff
- Next phase: DEPLOYER_AGENT, only after user approval
- Stopping here per role rules; not invoking deployer-agent or running phase-close/complete-phase.
