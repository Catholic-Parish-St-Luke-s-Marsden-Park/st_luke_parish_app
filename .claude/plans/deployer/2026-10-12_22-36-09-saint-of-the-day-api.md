# DEPLOYER_AGENT Plan

- Feature ID: 09
- Feature Slug: saint-of-the-day-api
- Branch: feature/09-saint-of-the-day-api
- Phase: deployer
- Timestamp: 2026-10-13_00-05
- Status: artifacts written, **awaiting user approval**

## Done
- **Baseline:** after `git fetch origin main`, HEAD is `81e180b`, the tree is clean, and the branch is 0 behind and 6 ahead of `origin/main` (`6ef2edd`). No rebase is needed. The branch is not on the remote yet.
- **Existing PRs:** not checked, because `gh` isn't on PATH in this shell. Since the branch isn't pushed, no PR can exist.
- **Local validation:**
  - `dart format` changed 0 files.
  - `flutter analyze` found no issues.
  - `flutter test` gave 611 passed / 2 skipped / 0 failed.
  - `flutter test --exclude-tags live` gave 606/2/0.
  - `flutter build apk --debug` succeeded.
  - `RELEASE_CHECK` passes `API_BASE_URL` and fails `BASE_URL`; the `BASE_URL` failure is pre-existing.
  - The tree was still clean afterwards.
- **Release config review:**
  - Nothing in `.github/workflows/ios-testflight.yml`, `ios/fastlane/Fastfile` or `android/` references `OPENROUTER_API_KEY` or needs a change. The branch touches none of those files.
  - The TestFlight workflow already writes production `API_BASE_URL` and `BASE_URL`.
- **Pre-existing finding:**
  - The committed `assets/app.env` has `BASE_URL=http://localhost:8080/tokens`, from `c698c41`.
  - CI iOS builds overwrite it. Local and Android release builds would not, so push registration would fail.
  - Flagged for the user and not modified.
- **Notes produced:**
  - Release readiness, including rollback: `.claude/releases/2026-10-12_22-36-09-saint-of-the-day-api-release-readiness.md`
  - PR readiness, including the draft title and body: `.claude/releases/2026-10-12_22-36-09-saint-of-the-day-api-pr-readiness.md`
- **Store metadata:** none needed. Saint of the Day already exists, and there are no new permissions, data collection or screens.

## Rollback
See the release readiness note. In short: revert the merge commit. There is no data migration, and the cache format is unchanged. A rolled-back build needs a valid OpenRouter key passed at build time to work.

## Open user decisions (not decided by Deployer)
1. **RISK-019:** revoke or rotate the old OpenRouter key, or set a spend cap. Ideally do this before merge.
2. **RISK-018:** coordinate with the parish_app_service owner, so App Check `enforce` waits for an App Check-capable release.
3. **RISK-007:** decide whether a plain `flutter test` should skip `live` tests by default.
4. **RISK-020:** optionally do a two-minute device check: airplane mode, largest font, and reopening from the cache.
5. **Verifier observation (CLAUDE.md wording):** the CLAUDE.md Project Overview still says the parish API serves "currently ministries" only. The main session will offer to update it; Deployer must not edit CLAUDE.md.
6. **Pre-existing:** the `BASE_URL` localhost value in `assets/app.env`. Resolve it before any local or Android release build. It's outside this PR.

## Handoff
After user approval: final checks, then push `feature/09-saint-of-the-day-api` and open the PR against `main` using the drafted title and body. Do not merge; merging stays manual in the GitHub UI.
