# PR Readiness — 08-ministries-api

## Merge-to-main checklist (`.claude/git/merge-to-main-checklist.md`)
- [x] Branch created from `main` (`aa91b85`)
- [x] BA phase complete. Condensed SDLC: the user approved one plan up front, so there were no per-phase approvals.
- [x] Coder phase complete
- [x] Tester phase complete
- [x] App-Visualiser phase complete. It was a scripted on-device smoke run on the iOS simulator, not a hands-on human review. No issues filed.
- [x] Verifier phase complete. Pass, with RISK-012/013 carried forward.
- [x] Deployer phase complete
- [x] Latest `main` fetched: `origin/main` = `aa91b85`
- [x] Feature branch rebased with latest `main`: not needed (0 behind)
- [x] Merge conflicts resolved: n/a
- [x] `dart format` completed: `lib/` and `test/` have 0 changes
- [x] `flutter analyze` completed: no issues
- [x] `flutter test` completed: 405 passed, 2 skipped
- [x] Build validation completed: iOS release build (no codesign) succeeded. Android was not built because there's no SDK on this machine.
- [x] Test summary updated
- [x] Verification report updated
- [x] Journal updated
- [x] Memory updated
- [x] PR description completed: `.claude/git/pr-templates/2026-10-08_10-51-08-ministries-api-pr.md`
- [x] User approval recorded: the plan approved at the start of the session covers pushing the branch and opening the PR. Merging stays manual.

## Suggested PR
- Title: `feat(08): load Ministries from the parish API`
- Base: `main`; head: `feature/08-ministries-api`
- Body: the filled template, plus `Closes #24`
