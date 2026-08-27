# PR Readiness Note — 03-multi-pages

- Feature ID: 03
- Feature Slug: multi-pages
- Branch: feature/03-multi-pages
- Timestamp: 2026-08-27_22-22
- Prepared by: DEPLOYER_AGENT

This note assesses whether the branch is ready for PR creation. **No PR has been opened yet for this feature** — confirmed via `gh pr list` this session, which shows only two unrelated open docs PRs (#10, #11). Opening the PR is explicitly **not** performed by this agent; that is the PR agent's job, after user approval.

## Merge-to-Main Checklist Status

- [x] Branch created from `main` — `feature/03-multi-pages` branched cleanly; `git fetch origin main` + rebase check confirm 0 commits behind.
- [x] BA phase complete and approved — plan artifact `.claude/plans/ba/2026-08-27_20-56-03-multi-pages.md`; approval logged in `.claude/memory.md` (2026-08-27, "BA plan for 03-multi-pages approved").
- [x] Coder phase complete and approved — plan artifact `.claude/plans/coder/2026-08-27_21-41-03-multi-pages.md`; approval logged in memory (2026-08-27, coder phase committed `ebfe6a5`).
- [x] Tester phase complete and approved — plan artifact `.claude/plans/tester/2026-08-27_21-58-03-multi-pages.md`; approval logged in memory (2026-08-27, tester phase committed `38d0673`).
- [x] App-Visualiser phase complete — plan artifact `.claude/plans/visualiser/2026-08-27_22-08-03-multi-pages.md`; user reported "no feedback. Everything looks good," no defects, no GitHub issues filed this phase.
- [x] Verifier phase complete and approved — verification report `.claude/verification/2026-08-27_22-20-03-multi-pages.md`, verdict CONDITIONAL PASS; user-approved per memory (2026-08-27, verifier phase committed `4a52862`).
- [~] Deployer phase complete — this note and the accompanying deployer plan/release-readiness note are this phase's artifacts; **awaiting user approval** (not yet approved as of this note).
- [x] Latest `main` fetched — `git fetch origin main` re-run this session; branch is 5 commits ahead, 0 behind.
- [x] Feature branch rebase status checked — **no rebase needed**: `git log --oneline feature/03-multi-pages..origin/main` is empty.
- [x] Merge conflicts — n/a, no rebase necessary (nothing to replay).
- [x] `dart format .` — re-run this session: `Formatted 67 files (0 changed)`, exit 0.
- [x] `flutter analyze` — re-run this session: `No issues found!`.
- [x] `flutter test` — re-run this session: `All tests passed!`, 98/98.
- [x] Build validation — re-run this session: `flutter build apk --debug` succeeded. **Note:** this is a debug build only and does not clear RISK-005 (release-build-only manifest gap) — see release readiness note.
- [x] Verification report reviewed — CONDITIONAL PASS, all 29 requirements have complete traceability; 3 open risks (RISK-003, RISK-004, RISK-005) explicitly carried forward, not silently dropped.
- [x] **Open risks resolved or explicitly accepted for merge** — **User decision (2026-08-27, logged in `.claude/memory.md`): ship as-is, with RISK-003, RISK-004, and RISK-005 all tracked in the PR** rather than fixed first, including explicit acknowledgement that RISK-005 is a confirmed production-blocking bug for the Donate tab, not merely an unconfirmed edge case. All three remain open in `.claude/risks/active-risks.md`, owned by Deployer/follow-up work, and are called out explicitly in the PR description below with RISK-005 given prominent, standalone disclosure per the user's explicit instruction.
- [x] Journal updated — `.claude/journal/2026-08-27_22-22-03-multi-pages-deployer.md`.
- [x] Memory updated — `.claude/memory.md` Active State header already reflects `deployer`/`DEPLOYER_AGENT`; this phase's session log entry to be appended.
- [x] PR description — drafted below, for the ship-as-is path (RISK-003/004/005 noted, not fixed).
- [ ] User approval recorded — **pending**: this note requires explicit user go-ahead on (a) this deployer phase's artifacts, and (b) final confirmation that RISK-005's severity does not change the ship-as-is decision already logged in memory, before PR creation proceeds.

## Suggested PR Title
`feat(03): multi-pages — Ministries, Contact, and Donate tabs`

## PR Description Draft

### Feature
- Feature ID: 03
- Feature Name: multi-pages
- Branch: feature/03-multi-pages

### Summary
- Scope: Replaces the Ministries, Contact, and Donate bottom-nav tabs' generic `PlaceholderScreen` stubs with real content.
  - **Ministries** (`lib/features/ministries/`): 16 ministries across 4 categories (static typed config), a grouped grid screen, and a detail screen per ministry with a mailto "Join Us" CTA. The ministry `emoji` field is intentionally never rendered anywhere in the UI (twice-corrected BA requirement, independently verified by both Tester and Verifier via exhaustive per-`Text`-widget assertions, not spot-checks).
  - **Contact** (`lib/features/contact/`): 8 static contact entries (phone/mobile/email/office/addresses/hours/Facebook/website) in an exact required order, plus a static map-preview card and an "Open in Google Maps" pill that both hand off to an external Google Maps URL (no embedded map SDK).
  - **Donate** (`lib/features/donate/` + new `lib/shared/webview/simple_webview_screen.dart`): a new in-app WebView (via the newly-added `webview_flutter: ^4.14.1` dependency) loading the parish's existing public donate page, with loading and retryable-error states.
  - Also fixes a real bug in the existing `UrlLauncherServiceImpl` (from 02-parish-tab): its host-required URL validation incorrectly rejected `tel:`/`mailto:` URIs, which would have silently broken every new Ministries/Contact external-link tap — narrowed to `http`/`https` only (ADR-0002). Masses, News, and the shared AppBar chrome are untouched.
- User value: Turns three more bottom-nav tabs from stubs into real, navigable content, including the parish's first in-app donation entry point and the app's first `tel:`/`mailto:` quick-action links.
- Risks: **3 open, tracked risks** — see `.claude/risks/active-risks.md`. **Please read RISK-005 first; it is more severe than RISK-003/004 and is not just "another item on the list."**
  - **RISK-005 (new this feature, most severe):** the release-build (`main`) `android/app/src/main/AndroidManifest.xml` is missing `android.permission.INTERNET` (only the `debug`/`profile` manifests carry it, for dev tooling). The Donate tab's WebView cannot load any content in a release/production Android build — every real user who opens Donate in a production build will see a permanent "Unable to load this page" error, 100% of the time, with no workaround. This is a confirmed, not speculative, gap (directly read from all three manifest variants by both the verifier-agent and the deployer-agent independently) that this feature's own commits did not introduce into the manifest (pre-existing gap; this feature's new WebView just exposes it as production-breaking). It was undetected by all prior testing because every test/run used a debug or profile build, which each independently carry their own dev-only `INTERNET` permission. **The user was explicitly told this before deciding to ship with it tracked rather than fixed.** Fix, if reconsidered: a single `<uses-permission android:name="android.permission.INTERNET"/>` line in the release manifest, then a release-mode build/run to confirm.
  - **RISK-003** (GitHub issue #12, scope now widened): the pre-existing Android `<queries>` gap (leadership-link taps silently no-op) now also confirmed to affect this feature's new `tel:`/`mailto:` launches (Ministries "Join Us" CTA, Contact Phone/Mobile/Email), not just `https:` links. Fix needs to cover all three schemes, not just `https`.
  - **RISK-004:** iOS `Info.plist` has no `LSApplicationQueriesSchemes` entry, same class of gap, unconfirmed on a real device — now also covering this feature's new launch points.
  - Reviewers: please weigh in on whether RISK-005 in particular should be fixed in this PR before merge — it is a one-line manifest change with disproportionately high severity (breaks a shipped feature for all production users) relative to its fix cost, distinct in kind from RISK-003/004's lower-severity, ship-and-track-appropriate gaps.

### Artifacts
- BA Plan: `.claude/plans/ba/2026-08-27_20-56-03-multi-pages.md`
- Coder Plan: `.claude/plans/coder/2026-08-27_21-41-03-multi-pages.md`
- Tester Plan: `.claude/plans/tester/2026-08-27_21-58-03-multi-pages.md`
- App-Visualiser Plan: `.claude/plans/visualiser/2026-08-27_22-08-03-multi-pages.md`
- Verifier Plan: `.claude/plans/verifier/2026-08-27_22-20-03-multi-pages.md`
- Deployer Plan: `.claude/plans/deployer/2026-08-27_22-22-03-multi-pages.md`
- Verification Report: `.claude/verification/2026-08-27_22-20-03-multi-pages.md`
- Release Readiness Note: `.claude/releases/2026-08-27_22-22-03-multi-pages-release-readiness.md`
- Active Risks: `.claude/risks/active-risks.md` (RISK-003, RISK-004, RISK-005)
- ADRs: `.claude/decisions/0002-url-launcher-tel-mailto-host-validation.md`, `.claude/decisions/0003-simple-webview-screen-bare-content.md`

### Validation (independently re-run by DEPLOYER_AGENT, 2026-08-27_22-22, fresh session on HEAD `4a52862`)
- Rebased with main: not needed — 0 commits behind `origin/main` (should be re-checked again immediately before PR creation, since time may pass between this note and actual PR-open)
- Merge conflicts: n/a (none occurred)
- dart format: pass (`Formatted 67 files (0 changed)`)
- flutter analyze: pass (`No issues found!`)
- flutter test: pass (98/98)
- build validation: pass (`flutter build apk --debug` succeeded — debug only, does not clear RISK-005)

### Approval
- User approval recorded: **not yet** — pending explicit user go-ahead on (a) this deployer phase's artifacts, and (b) final confirmation that shipping with RISK-005 tracked (rather than fixed) still stands given this note's prominent restatement of its severity.

## What Happens After This Note (not performed by this agent)
1. User reviews this deployer phase and the release readiness note's RISK-005 disclosure, and gives final confirmation to proceed with the already-logged ship-as-is decision (or reconsiders it).
2. Re-confirm `main` hasn't moved and no rebase is newly needed (0 behind as of this session; re-check at PR-open time).
3. `git push -u origin feature/03-multi-pages`.
4. `gh pr create` against the `Catholic-Parish-St-Luke-s-Marsden-Park` org repo, targeting `main`, using the PR description above as the body.
5. Update `.claude/context/feature-index.md` PR Status column and `.claude/memory.md` with the resulting PR URL.

Merging remains manual, via the GitHub UI, by the user. No `gh pr create` or `gh pr merge` command was run by this agent in this session. No rebase, push, or PR creation performed.
