# PR Readiness Note — 02-parish-tab

- Feature ID: 02
- Feature Slug: parish-tab
- Branch: feature/02-parish-tab
- Timestamp: 2026-08-26_23-40
- Prepared by: DEPLOYER_AGENT

This note assesses whether the branch is ready for PR creation. **No PR has been opened yet for this feature** (unlike feature 01, which has merged PR #1) — confirmed via `gh pr list` this session, which shows only PRs #1 (merged, feature 01), #2/#3 (merged, refactoring), #10/#11 (open, unrelated docs branches). Opening the PR is explicitly **not** performed by this agent; that is the PR agent's job, after user approval.

## Merge-to-Main Checklist Status (`.claude/git/merge-to-main-checklist.md`)

- [x] Branch created from `main` — confirmed via `git merge-base feature/02-parish-tab main` == `63a2bc8`, i.e. the branch's root is `main`'s state at feature start.
- [x] BA phase complete and approved — plan artifact `.claude/plans/ba/2026-08-26_18-54-02-parish-tab.md`; approval logged in `.claude/memory.md` (2026-08-26_19-50).
- [x] Coder phase complete and approved — plan artifact `.claude/plans/coder/2026-08-26_21-05-02-parish-tab.md`; approval logged in memory (2026-08-26_21-30).
- [x] Tester phase complete and approved — plan artifact `.claude/plans/tester/2026-08-26_22-53-02-parish-tab.md`; approval logged in memory (2026-08-26_23-00).
- [x] App-Visualiser phase complete — plan artifact `.claude/plans/visualiser/2026-08-26_23-15-02-parish-tab.md`; 4 issues filed (#12-#15), proceeds to Verifier regardless per visualiser-agent rules.
- [x] Verifier phase complete and approved — verification report `.claude/verification/2026-08-26_23-18-02-parish-tab.md`, verdict CONDITIONAL PASS; user-approved per memory (2026-08-26_23-25).
- [~] Deployer phase complete — this note and the accompanying deployer plan/release-readiness note are this phase's artifacts; **awaiting user approval** (not yet approved as of this note).
- [x] Latest `main` fetched — `git fetch origin main` re-run this session; `origin/main` tip `63a2bc8` unchanged from the branch's own merge-base.
- [x] Feature branch rebase status checked — **no rebase needed**: `git log --oneline feature/02-parish-tab..origin/main` is empty (0 commits behind); branch is 6 commits ahead of `main`. `main` has not moved since this branch was created.
- [x] Merge conflicts — n/a, no rebase necessary (nothing to replay).
- [x] `dart format .` — re-run this session: `Formatted 49 files (0 changed)`, exit 0.
- [x] `flutter analyze` — re-run this session: `No issues found!`.
- [x] `flutter test` — re-run this session: `All tests passed!`, 58/58.
- [x] Build validation — re-run this session: `flutter build apk --debug` succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).
- [x] Verification report reviewed — CONDITIONAL PASS, all 29 requirements have complete traceability; 2 open risks (RISK-003, RISK-004) explicitly carried forward, not silently dropped.
- [x] **Open risks resolved or explicitly accepted for merge** — **User decision (2026-08-26_23-58): ship as-is, with RISK-003 and RISK-004 both tracked in the PR** rather than fixed first. Both remain open in `.claude/risks/active-risks.md`, owned by Deployer/follow-up work per that file, and are called out explicitly in the PR description below for reviewer visibility.
- [x] Journal updated — `.claude/journal/2026-08-26_23-40-02-parish-tab-deployer.md`, `.claude/journal/2026-08-26_23-52-02-parish-tab-feature-close.md`.
- [x] Memory updated — `.claude/memory.md` Active State header corrected to `deployer`/`DEPLOYER_AGENT`.
- [x] PR description — drafted below, finalized for the ship-as-is path (RISK-003/004 noted, not fixed).
- [x] User approval recorded — **2026-08-26_23-58: user approved shipping as-is with RISK-003/RISK-004 tracked in the PR.**

## Suggested PR Title
`feat(02): parish-tab — Parish tab content, shared AppBar chrome, Ask Luke assistant`

## PR Description Draft (per `.claude/git/pr-template.md`)

### Feature
- Feature ID: 02
- Feature Name: parish-tab
- Branch: feature/02-parish-tab

### Summary
- Scope: Replaces the Parish bottom-nav tab's generic `PlaceholderScreen` with real content — a hero banner (revised subtext, no eyebrow label), an "About St Luke's" section, and a 3-part "Church Leadership" section (Universal Church / Diocese of Parramatta / Parish) with locally bundled leadership images and external-link taps. Also introduces the shared app-level AppBar chrome used across all 6 tabs (parish wordmark logo, "Saint of the Day" placeholder pill, "Ask Luke" pill), and a new `lib/features/ask_luke/` feature module — a full-screen, hardcoded-response quick-reply assistant with 4 topic chips and no free-text input. The other 5 tabs' own body content (Masses, News, Ministries, Contact, Donate) is untouched; only the shared AppBar chrome they all inherit changes, identically for all of them.
- User value: Turns the Parish tab from a stub into real, navigable content, and adds app-wide chrome (branding logo + 2 quick-access pills) that every tab benefits from, including a first lightweight "assistant" surface (Ask Luke) ahead of any real backend/AI integration.
- Risks: **2 open, tracked risks** — see `.claude/risks/active-risks.md`:
  - **RISK-003** (GitHub issue #12): Church Leadership entry taps (Pope Leo XIV, Bishop Vincent Long, Fr Gayan Thamel) silently fail to open an external browser on real Android devices/emulators — confirmed live, root-caused to a missing `<queries>` block in `android/app/src/main/AndroidManifest.xml` (Android 11+ package-visibility requirement for `url_launcher`). Fix is scoped and documented in issue #12; not yet applied as of this PR.
  - **RISK-004**: iOS `Info.plist` has no `LSApplicationQueriesSchemes` entry for the same class of gap — unconfirmed either way, no iOS run performed for this feature yet.
  - Also see GitHub issues **#13, #14, #15** (visualiser-phase clarification questions — section order, Parish-tab iconography, color scheme — not confirmed bugs, filed for follow-up discussion, not blocking).
  - Reviewers: please weigh in on whether RISK-003 should be fixed in this PR (small, well-scoped manifest change) or tracked as a fast-follow before approving.

### Artifacts
- BA Plan: `.claude/plans/ba/2026-08-26_18-54-02-parish-tab.md`
- Coder Plan: `.claude/plans/coder/2026-08-26_21-05-02-parish-tab.md`
- Tester Plan: `.claude/plans/tester/2026-08-26_22-53-02-parish-tab.md`
- App-Visualiser Plan: `.claude/plans/visualiser/2026-08-26_23-15-02-parish-tab.md`
- Verifier Plan: `.claude/plans/verifier/2026-08-26_23-18-02-parish-tab.md`
- Deployer Plan: `.claude/plans/deployer/2026-08-26_23-40-02-parish-tab.md`
- Verification Report: `.claude/verification/2026-08-26_23-18-02-parish-tab.md`
- Release Readiness Note: `.claude/releases/2026-08-26_23-40-02-parish-tab-release-readiness.md`
- Active Risks: `.claude/risks/active-risks.md` (RISK-003, RISK-004)

### Validation (independently re-run by DEPLOYER_AGENT, 2026-08-26_23-40)
- Rebased with main: not needed — 0 commits behind `origin/main` (branch already up to date as of this session; should be re-checked again immediately before PR creation, since time may pass between this note and actual PR-open)
- Merge conflicts: n/a (none occurred)
- dart format: pass (`Formatted 49 files (0 changed)`)
- flutter analyze: pass (`No issues found!`)
- flutter test: pass (58/58)
- build validation: pass (`flutter build apk --debug` succeeded)

### Approval
- User approval recorded: **not yet** — pending explicit user go-ahead on both (a) this deployer phase's artifacts, and (b) the RISK-003 fix-before-merge-vs-ship-with-tracking decision.

## `/feature-close` Re-Confirmation (2026-08-26_23-52)

Re-ran the full pre-PR checklist as a fresh pass: `git fetch origin main` (still `63a2bc8`, unchanged), rebase check (still 0 commits behind, no rebase needed, no conflicts), `flutter analyze` (No issues found!), `dart format . --set-exit-if-changed` (49 files, 0 changed), `flutter test` (58/58 passing). All results identical to the deployer phase's original run — nothing has drifted. **RISK-003/RISK-004 remain open and undecided** — this pass does not resolve that decision, only re-confirms everything else on the checklist is still accurate.

## What Happens After This Note (not performed by this agent)
1. User reviews this deployer phase and the release readiness note's RISK-003/004 recommendation, and decides: fix RISK-003 first (small Coder follow-up + live Android re-verification) or proceed with it tracked.
2. Re-confirm `main` hasn't moved and no rebase is newly needed (0 behind as of this session; re-check at PR-open time).
3. `git push -u origin feature/02-parish-tab`.
4. `gh pr create` against the `Catholic-Parish-St-Luke-s-Marsden-Park` org repo, targeting `main`, using the PR description above (updated to reflect the RISK-003 decision) as the body.
5. Update `.claude/context/feature-index.md` PR Status column and `.claude/memory.md` with the resulting PR URL.

Merging remains manual, via the GitHub UI, by the user. No `gh pr create` or `gh pr merge` command was run by this agent in this session.
