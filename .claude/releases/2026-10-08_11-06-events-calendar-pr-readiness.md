# PR Readiness Note — 08-events-calendar

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Timestamp: 2026-10-08_11-06
- Prepared by: DEPLOYER_AGENT

This note assesses whether the branch is ready for PR creation. **No PR has been opened yet for this feature.** Opening the PR is explicitly **not** performed by this agent; that is the PR agent's job, after user approval. `gh` CLI availability on the user's own machine is **unconfirmed** as of this note (only checked, and not found, in this cloud session's own bridge shell, which is a different environment — see the deployer plan) — needs a direct check on the user's machine at PR-agent time.

## Merge-to-Main Checklist Status

- [x] Branch created from `main` — `feature/08-events-calendar`; user-run `git fetch origin main` + rebase check this phase confirm 0 commits behind, 14 ahead.
- [x] BA phase complete and approved — plan artifact `.claude/plans/ba/2026-10-01_11-15-09-events-calendar.md`; approval logged in `.claude/memory.md`.
- [x] Coder phase complete and approved — plan artifact `.claude/plans/coder/2026-10-01_11-15-09-events-calendar.md`; approval logged in memory (357-test baseline minus this round's 3 additions = 314 at coder close).
- [x] Tester phase complete and approved — plan artifact `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`; found and logged RISK-012 (deferred, not fixed), closed a testability gap (`CalendarExportService`), added 4 new test files.
- [x] App-Visualiser phase complete and approved — plan artifact `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md`; 3 live-feedback rounds plus a round-2.5 tweak pass, all user-confirmed via screenshots, final "yes" on 2026-10-07.
- [x] Verifier phase complete and approved — verification report `.claude/verification/2026-10-07_10-22-events-calendar.md`, verdict CONDITIONAL PASS; approval logged in memory.
- [x] Post-verifier review-fix round complete — RISK-013 and the RISK-014 it led to finding, both found via real live-device testing, fixed (commit `c21ed4c`), and confirmed resolved live by the user on the same Android emulator. Logged in `.claude/memory.md`'s 2026-10-08 entry.
- [~] Deployer phase complete — this note and the accompanying deployer plan/release readiness note are this phase's artifacts; **awaiting user approval** (not yet approved as of this note).
- [x] Latest `main` fetched — user ran `git fetch origin main` this session.
- [x] Feature branch rebase status checked — **no rebase needed**: 14 commits ahead of `origin/main`, 0 behind.
- [x] Merge conflicts — n/a, no rebase necessary (nothing to replay).
- [x] `dart format .` — user-run this session: `0 changed` (166 files), exit 0.
- [x] `flutter analyze` — user-run this session: clean, no issues.
- [x] `flutter test` — user-run this session: `357 passed / 1 skipped / 0 failed`.
- [x] Build validation — user-run this session: `flutter build apk --debug` succeeded.
- [x] Verification report reviewed — CONDITIONAL PASS, all 39 requirements have complete traceability (34 direct, 5 retired, 1 amended); risks assessed below.
- [x] **Open risks resolved or explicitly accepted for merge** — RISK-013/RISK-014 resolved and confirmed live this session. **RISK-012 remains open by explicit user decision** (deferred to a future Coder follow-up, not this PR), called out standalone in the PR description below. RISK-003/004 confirmed to extend to this feature's 2 new external-link tap targets (open, project-wide, unrelated to this feature specifically); RISK-005 confirmed already covered.
- [x] Memory updated — `.claude/memory.md` Latest Session Logs entries appended for the review-fix round and this deployer phase.
- [x] PR description — drafted below.
- [ ] User approval recorded — **pending**: this note requires explicit user go-ahead on this deployer phase's artifacts before PR creation proceeds.

## Suggested PR Title
`feat(08): events-calendar — live upcoming-events feed with calendar export`

## PR Description Draft

### Feature
- Feature ID: 08
- Feature Name: events-calendar
- Branch: feature/08-events-calendar

### Summary
- Scope: Adds a live "Upcoming Events" section to the News tab (`lib/features/events/`), sourced from the parish website's AI1EC ICS calendar feed (RRULE-expanded recurring events, `Australia/Sydney`-aware parsing), with inline weekly pagination, a per-event "Add to my calendar" device-calendar export, and an in-app Details bottom sheet.
- User value: parishioners can see what's coming up without leaving the app, and add any event straight to their phone's calendar.
- Risks: **2 risks found and fixed in a post-verifier live-device round (RISK-013, RISK-014), 1 open by explicit user decision (RISK-012), 2 confirmed-already-covered-or-extended (RISK-003/004/005).**
  - **RISK-013/RISK-014 (found and fixed after the verifier phase, before this PR):** the verifier phase flagged that no visualiser round had ever live-tested tapping "Add to my calendar" and watching the native calendar app actually open. The user then did exactly that and found it genuinely failing (missing Android manifest `<queries>` entry for Android 11+ package-visibility rules), fixed it, then found the newly-opening calendar showed the wrong date/time (an internal "fake UTC" value passed unconverted to the `add_2_calendar` plugin), fixed that too with a new timezone-conversion helper and 3 pinning unit tests. Both confirmed resolved live, same emulator, after rebuilding.
  - **RISK-012 (open, deferred):** an in-progress event (started but not yet ended) is excluded from the upcoming list for its own duration, due to a narrower-than-spec filter comparing `start` alone. Low severity, narrow window. **User's explicit decision: defer to a future, small Coder follow-up** rather than fix in this feature.
  - **RISK-003/RISK-004:** confirmed to **extend** to this feature's 2 new `https:` tap targets (no new scheme type) — same open, project-wide item every recent feature has carried.
  - **RISK-005:** confirmed **already covered** — the existing Android `INTERNET` permission already covers this feature's ICS feed fetch.
  - Reviewers: no specific review-time ask beyond the usual code review; RISK-012's fix (if wanted) is a small, isolated follow-up to the recurrence-expansion filtering logic, not something this PR needs to block on.

### Artifacts
- BA Plan: `.claude/plans/ba/2026-10-01_11-15-09-events-calendar.md`
- Coder Plan: `.claude/plans/coder/2026-10-01_11-15-09-events-calendar.md`
- Tester Plan: `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`
- App-Visualiser Plan: `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md`
- Verifier Plan: `.claude/plans/verifier/2026-10-07_10-22-events-calendar.md`
- Deployer Plan: `.claude/plans/deployer/2026-10-08_11-06-events-calendar.md`
- Verification Report: `.claude/verification/2026-10-07_10-22-events-calendar.md`
- Release Readiness Note: `.claude/releases/2026-10-08_11-06-events-calendar-release-readiness.md`
- ADR: `.claude/decisions/0006-events-ics-rrule-and-robots-scope.md`
- Active Risks: `.claude/risks/active-risks.md` (RISK-003, RISK-004, RISK-005, RISK-012, RISK-013, RISK-014)

### Validation (user-run, 2026-10-08, fresh session on HEAD `670cd4a`)
- Rebased with main: not needed — 0 commits behind `origin/main` (re-check again immediately before PR creation)
- Merge conflicts: n/a (none occurred)
- dart format: pass (`0 changed`, 166 files)
- flutter analyze: pass (clean)
- flutter test: pass (357 passed / 1 skipped / 0 failed)
- build validation: pass (`flutter build apk --debug` succeeded)

### Approval
- User approval recorded: **not yet** — pending explicit user go-ahead on this deployer phase's artifacts.

## What Happens After This Note (not performed by this agent)
1. User reviews this deployer phase, the release readiness note's RISK-012/013/014 disclosures, and gives final confirmation to proceed.
2. Re-confirm `main` hasn't moved and no rebase is newly needed (0 behind as of this session; re-check at PR-open time).
3. Confirm `gh` CLI availability on the user's own machine (unconfirmed as of this note — install it, or plan to open the PR manually via the GitHub web UI).
4. `git push -u origin feature/08-events-calendar`.
5. Open the PR against the `Catholic-Parish-St-Luke-s-Marsden-Park` org repo, targeting `main`, using the PR description above as the body.
6. Update `.claude/context/feature-index.md` PR Status column and `.claude/memory.md` with the resulting PR URL.

Merging remains manual, via the GitHub UI, by the user. No push or PR creation performed by this agent in this session.
