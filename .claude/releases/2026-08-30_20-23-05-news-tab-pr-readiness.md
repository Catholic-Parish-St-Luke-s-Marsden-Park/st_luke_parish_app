# PR Readiness Note — 05-news-tab

- Feature ID: 05
- Feature Slug: news-tab
- Branch: feature/05-news-tab
- Timestamp: 2026-08-30_20-23
- Prepared by: DEPLOYER_AGENT

This note assesses whether the branch is ready for PR creation. **No PR has been opened yet for this feature** — confirmed via `gh pr list` this session, which currently shows no open PRs at all. Opening the PR is explicitly **not** performed by this agent; that is the PR agent's job, after user approval.

## Merge-to-Main Checklist Status

- [x] Branch created from `main` — `feature/05-news-tab` branched cleanly.
- [x] BA phase complete and approved — plan artifact `.claude/plans/ba/2026-08-30_19-06-05-news-tab.md`; approval logged in `.claude/memory.md`.
- [x] Coder phase complete and approved — plan artifact `.claude/plans/coder/2026-08-30_19-06-05-news-tab.md` (commit `2d99b9f`).
- [x] Tester phase complete and approved — plan artifact `.claude/plans/tester/2026-08-30_19-06-05-news-tab.md` (commit `c560357`).
- [x] App-Visualiser phase complete and approved — plan artifact `.claude/plans/visualiser/2026-08-30_20-15-05-news-tab.md` (commit `6da5057`); live iOS Simulator run confirmed all 3 new external-link tap targets (Download PDF, Submit Prayer Request, bulletins-archive fallback) work end-to-end, plus live network fetch — the user gave an explicit itemized pass, a stronger bar than 04-masses-tab's visualiser sign-off.
- [x] Verifier phase complete and approved — verification report `.claude/verification/2026-08-30_21-45-05-news-tab.md` (commit `f21c9ca`), verdict CONDITIONAL PASS, all 38 requirements (REQ-F05-001..038) independently re-verified with complete traceability.
- [~] Deployer phase complete — this note and the accompanying deployer plan/release-readiness note are this phase's artifacts; **awaiting user approval**, including an explicit RISK-005 decision (fix-now vs. ship-and-track — see release readiness note).
- [x] Latest `main` fetched — `git fetch origin main` re-run this session.
- [x] Feature branch rebase status checked — **no rebase needed**. `git rev-list --left-right --count origin/main...feature/05-news-tab` → `0  6`; `git merge-base feature/05-news-tab origin/main` equals `origin/main`'s current tip (`84decbe`) exactly, confirming this branch already contains 04-masses-tab's merge (PR #18) at its base despite `main` having moved since this feature's branch point.
- [x] Merge conflicts — n/a, no rebase necessary (nothing to replay).
- [x] `dart format .` — re-run this session: `Formatted 109 files (0 changed)`, exit 0.
- [x] `flutter analyze` — re-run this session: `No issues found!`.
- [x] `flutter test` — re-run this session: `All tests passed!`, 175/175, including both live RSS tests against the real feed.
- [x] Build validation — re-run this session: `flutter build apk --debug` succeeded.
- [x] Verification report reviewed — CONDITIONAL PASS, all 38 requirements have complete traceability; 4 open risks touching this feature (RISK-005 most severe for News specifically, RISK-003/004 extended scope, RISK-007 new test-infrastructure gap), none silently dropped.
- [ ] **Open risks resolved or explicitly accepted for merge** — **pending user decision**, specifically:
  - RISK-005: user must choose fix-now (single manifest line, before merge) vs. ship-and-track (prior 03/04 precedent) — this decision has NOT yet been made for this feature, unlike RISK-003/004 whose ship-as-is stance was already established across prior features.
  - RISK-003/RISK-004: prior ship-and-track stance (established across 02/03/04) presumed to carry forward unless the user says otherwise; scope now extended to this feature's 3 new tap targets.
  - RISK-007: presumed track-only (test-infrastructure gap, no production impact) unless the user says otherwise.
- [x] Journal updated — `.claude/journal/2026-08-30_20-23-05-news-tab-deployer.md`.
- [x] Memory updated — `.claude/memory.md` Latest Session Logs entry appended this phase.
- [x] PR description — drafted below.
- [ ] User approval recorded — **pending**: this note requires explicit user go-ahead on (a) this deployer phase's artifacts, (b) the RISK-005 fix-now-vs-track decision specifically, and (c) confirmation that the RISK-003/004/007 carry-forward stance still stands, before PR creation proceeds.

## Suggested PR Title
`feat(05): news-tab — live bulletin feed, parish announcements, and prayer intentions`

## PR Description Draft

### Feature
- Feature ID: 05
- Feature Name: news-tab
- Branch: feature/05-news-tab

### Summary
- Scope: Replaces the News bottom-nav tab's `PlaceholderScreen` stub with real content (`lib/features/news/`):
  - **"Latest Bulletins" section** — live-fetched via RSS (`https://stlukesmarsdenpark.org.au/category/bulletins/feed/`), parsed with a regex+fallback-chain approach documented in ADR-0004 (a deliberate, well-justified deviation from CLAUDE.md's CSS-selector-first default — see Artifacts), newest-first, capped at 6 items, LATEST/PREVIOUS labeling, full loading/success/empty/parsing-failure/network-failure UI states.
  - **"Parish News" section** — 2 static announcements from typed config, no scraping.
  - **"Prayer Intentions" section** — static quote/body plus a "Submit Prayer Request ↗" external CTA.
  - New core additions: `lib/core/network/http_client_provider.dart` (shared `http.Client` provider), `lib/core/constants/external_links.dart` (centralized external URL constants).
  - New dependencies: `http: ^1.2.2`, `xml: ^6.5.0`.
- User value: Turns the News tab from a stub into a live source of parish bulletins and announcements, with a direct path to submitting prayer requests.
- Risks: **4 open, tracked risks touching this feature** — see `.claude/risks/active-risks.md`. **Please read RISK-005 first for this PR specifically — its severity is materially higher for News than for any prior feature.**
  - **RISK-005 (pre-existing, severity newly elevated by this feature):** the release-build Android manifest (`android/app/src/main/AndroidManifest.xml`) is missing `android.permission.INTERNET`. This feature is the app's first to make its own raw `http` call for primary tab content (the bulletins RSS fetch) rather than delegating to a WebView. **Without this permission, the entire "Latest Bulletins" section — not just an ancillary feature — would fail to load for every production Android user**, in addition to the pre-existing Donate-tab impact. The fix is a single manifest line with no `lib/`/`test/` impact. **The user has not yet decided whether to fix this before merging this PR or continue the prior ship-and-track precedent from 03-multi-pages/04-masses-tab** — this is presented as an open decision, not a default.
  - **RISK-003/RISK-004 (pre-existing, from 02-parish-tab/03-multi-pages, scope extended by this feature):** Android `<queries>`/iOS `LSApplicationQueriesSchemes` gaps now also cover this feature's 3 new `https:` tap targets (Download PDF, bulletins-archive fallback link, Submit Prayer Request CTA). Notably, this feature's own Visualiser phase live-confirmed all 3 work correctly on iOS Simulator — the strongest on-device evidence yet for RISK-004, though it doesn't fully close it project-wide. No Android live-device run was performed for this feature.
  - **RISK-007 (new this feature):** the 2 live RSS integration tests are not isolated/skippable for offline or sandboxed CI runs (no `dart_test.yaml` tagging convention exists in this repo yet). Would surface as a false-failure signal, not a real regression, if `flutter test` is ever run without network access. Test-infrastructure gap only, no production impact.
  - Reviewers: the practical ask for this PR is an explicit go/no-go on RISK-005's fix-now-vs-track question before merge; RISK-003/004/007 are informational continuity items consistent with prior PRs.

### Artifacts
- BA Plan: `.claude/plans/ba/2026-08-30_19-06-05-news-tab.md`
- Coder Plan: `.claude/plans/coder/2026-08-30_19-06-05-news-tab.md`
- Tester Plan: `.claude/plans/tester/2026-08-30_19-06-05-news-tab.md`
- Verifier Plan/Report: `.claude/verification/2026-08-30_21-45-05-news-tab.md`
- Deployer Plan: `.claude/plans/deployer/2026-08-30_20-23-05-news-tab.md`
- Release Readiness Note: `.claude/releases/2026-08-30_20-23-05-news-tab-release-readiness.md`
- ADR: `.claude/decisions/0004-news-rss-regex-vs-css-selector.md`
- Active Risks: `.claude/risks/active-risks.md` (RISK-003, RISK-004, RISK-005, RISK-007)

### Validation (independently re-run by DEPLOYER_AGENT, 2026-08-30_20-23, fresh session on HEAD `f21c9ca`)
- Rebased with main: not needed — branch's merge-base already equals `origin/main`'s current tip (0 commits behind); re-check again immediately before PR creation
- Merge conflicts: n/a (none occurred)
- dart format: pass (`Formatted 109 files (0 changed)`)
- flutter analyze: pass (`No issues found!`)
- flutter test: pass (175/175, including both live RSS tests)
- build validation: pass (`flutter build apk --debug` succeeded)

### Approval
- User approval recorded: **not yet** — pending explicit user go-ahead on (a) this deployer phase's artifacts, (b) the RISK-005 fix-now-vs-track decision, and (c) confirmation that carrying RISK-003/004/007 forward still stands.

## What Happens After This Note (not performed by this agent)
1. User reviews this deployer phase and the release readiness note's RISK-005 disclosure, and makes an explicit decision: fix RISK-005's manifest line now (before PR/merge) or carry it forward per the 03/04 precedent (with a firm commitment to fix before an actual release build is produced).
2. Re-confirm `main` hasn't moved further and no rebase is newly needed (0 behind as of this session; re-check at PR-open time).
3. If RISK-005 fix-now is chosen: a targeted Coder-scoped manifest edit (`android/app/src/main/AndroidManifest.xml`) plus a `flutter build apk --release` verification, committed separately from this deployer phase's docs-only artifacts.
4. `git push -u origin feature/05-news-tab`.
5. `gh pr create` against the `Catholic-Parish-St-Luke-s-Marsden-Park` org repo, targeting `main`, using the PR description above as the body (updated to reflect the RISK-005 decision made in step 1).
6. Update `.claude/context/feature-index.md` PR Status column and `.claude/memory.md` with the resulting PR URL.

Merging remains manual, via the GitHub UI, by the user. No `gh pr create` or `gh pr merge` command was run by this agent in this session. No rebase, push, PR creation, or manifest edit performed by this agent.
