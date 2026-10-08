# Pull Request Template

## Feature
- Feature ID: 08
- Feature Name: events-calendar
- Branch: feature/08-events-calendar

## Summary
- Scope: Adds a live "Upcoming Events" section to the News tab (`lib/features/events/`), sourced from the parish website's AI1EC ICS calendar feed (RRULE-expanded recurring events, `Australia/Sydney`-aware parsing), with inline weekly pagination, a per-event "Add to my calendar" device-calendar export, and an in-app Details bottom sheet.
- User value: parishioners can see what's coming up without leaving the app, and add any event straight to their phone's calendar.
- Risks: 2 risks found and fixed in a post-verifier live-device round (RISK-015, RISK-016), 1 open by explicit user decision (RISK-014), 2 confirmed-already-covered-or-extended (RISK-003/004/005). Full detail in the release readiness note.

## Artifacts
- BA Plan: `.claude/plans/ba/2026-10-01_11-15-09-events-calendar.md`
- Coder Plan: `.claude/plans/coder/2026-10-01_11-15-09-events-calendar.md`
- Tester Plan: `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`
- Verifier Plan: `.claude/plans/verifier/2026-10-07_10-22-events-calendar.md`
- Deployer Plan: `.claude/plans/deployer/2026-10-08_11-06-events-calendar.md`
- Verification Report: `.claude/verification/2026-10-07_10-22-events-calendar.md`
- Latest Journal: `.claude/journal/2026-10-07_10-22-events-calendar-verifier.md`
- Memory: `.claude/memory.md` (2026-10-08 deployer entry)

## Validation
- Rebased with main: not needed (0 behind `origin/main`, 14 ahead, confirmed via `git fetch origin main` on 2026-10-08)
- Merge conflicts resolved: n/a (none occurred)
- dart format: pass (`0 changed`, 166 files)
- flutter analyze: pass (clean)
- flutter test: pass (357 passed / 1 skipped / 0 failed)
- build validation: pass (`flutter build apk --debug` succeeded)

## Approval
- User approval recorded: deployer phase approved by the user 2026-10-08; push/PR-open approved separately the same day. PR opened manually via GitHub's web UI (gh CLI confirmed not installed on the user's machine): https://github.com/Catholic-Parish-St-Luke-s-Marsden-Park/st_luke_parish_app/pull/27
