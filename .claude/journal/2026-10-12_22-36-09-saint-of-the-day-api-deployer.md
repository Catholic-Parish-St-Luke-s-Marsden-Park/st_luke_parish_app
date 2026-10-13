# Journal — Deployer Phase — 09-saint-of-the-day-api

- Timestamp: 2026-10-13_00-05
- Branch: `feature/09-saint-of-the-day-api`
- Verifier commit: `81e180b`

## What was done
- **Baseline:** after `git fetch origin main`, HEAD is `81e180b`, the tree is clean, and the branch is 0 behind and 6 ahead of `origin/main` (`6ef2edd`). No rebase was needed, and the branch is not pushed.
- **Validation:**
  - `dart format` changed 0 files.
  - `flutter analyze` found no issues.
  - `flutter test` gave 611/2/0, and the live saint test passed against production.
  - `--exclude-tags live` gave 606/2/0.
  - `flutter build apk --debug` succeeded.
  - `RELEASE_CHECK` passed `API_BASE_URL` and failed `BASE_URL`; the failure is pre-existing.
  - iOS was not built, because this is a Windows machine.
- **Release config review:**
  - CI (`ios-testflight.yml`), fastlane and `android/` need no change. None of them ever passed `OPENROUTER_API_KEY`.
  - This supports the BA finding that store builds probably showed "isn't set up". That finding is still unverified.
- **Pre-existing finding:**
  - `assets/app.env` has `BASE_URL=http://localhost:8080/tokens` (`c698c41`).
  - The TestFlight workflow overwrites it; local and Android release builds do not.
  - Flagged for the user and left unmodified.
- **Not done:** no commit, push, PR or orchestrator run, and no edits to `assets/app.env` or CLAUDE.md.

## Outputs
- Deployer plan: `.claude/plans/deployer/2026-10-12_22-36-09-saint-of-the-day-api.md`
- Release readiness, including rollback: `.claude/releases/2026-10-12_22-36-09-saint-of-the-day-api-release-readiness.md`
- PR readiness, including the draft PR title and body: `.claude/releases/2026-10-12_22-36-09-saint-of-the-day-api-pr-readiness.md`

## Stopping point
Awaiting user approval. Open decisions:
- RISK-019: the OpenRouter key
- RISK-018: App Check enforce
- RISK-007: live tests by default
- RISK-020: the optional device check
- the CLAUDE.md wording (verifier observation)
- the pre-existing `BASE_URL` value
