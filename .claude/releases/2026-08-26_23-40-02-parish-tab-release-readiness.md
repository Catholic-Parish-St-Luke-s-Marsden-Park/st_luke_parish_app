# Release Readiness Note — 02-parish-tab

- Feature ID: 02
- Feature Slug: parish-tab
- Branch: feature/02-parish-tab
- Timestamp: 2026-08-26_23-40
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-08-26_23-18-02-parish-tab.md`). All 29 BA-approved requirements (REQ-F02-001..029, incl. REQ-F02-016a) have complete code and test traceability, and every test was independently re-confirmed passing. The condition on this pass is **not** about test/tooling health — it is a **confirmed, root-caused, live-device defect** affecting 3 of 29 requirements (REQ-F02-005/006/007: Church Leadership external-link taps silently no-op on real Android devices) plus one unconfirmed analogous risk on iOS. Both remain **open** as of this phase; neither has been resolved.

This note assesses **local release readiness** (buildability, test health, tooling cleanliness) and gives an explicit recommendation on the two open risks. It does not authorize a PR or merge, and does not decide the RISK-003/004 trade-off unilaterally — that decision is left to the user (see "Recommendation" below).

## Local Validation Evidence (independently re-run this session, 2026-08-26_23-40)

| Command | Result |
|---|---|
| `flutter --version` | Flutter 3.41.2 (stable), Dart 3.11.0 |
| `flutter pub get` | Succeeded — 29 packages have newer versions available but within constraint; no forced upgrades |
| `flutter analyze` | `No issues found!` |
| `dart format . --set-exit-if-changed` | `Formatted 49 files (0 changed)`, exit 0 |
| `flutter test` | `All tests passed!` — 58/58, matches tester (`.claude/plans/tester/2026-08-26_22-53-02-parish-tab.md`) and verifier (`.claude/verification/2026-08-26_23-18-02-parish-tab.md`) counts exactly |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |

No release build (`flutter build apk --release`, `flutter build appbundle`, `flutter build ios --release`) was run in this session, consistent with feature 01's deployer precedent — not required to unblock this PR since Phase 1 has no store submission planned yet.

## Working Tree / Git State
- Current branch: `feature/02-parish-tab`
- Working tree: clean (`git status --short` empty) except this phase's own new artifacts
- `git fetch origin main` re-run this session: `origin/main` tip is `63a2bc8`, which is exactly this branch's merge-base — branch is 6 commits ahead of `main`, **0 behind**. No rebase required at this time (re-checked in the PR readiness note as well, since `main` could still move before the PR is actually opened).
- No secrets, tokens, or credentials observed in the files this feature added/changed (`git diff --stat main..feature/02-parish-tab` reviewed).

## Open Risks and Recommendation (RISK-003 / RISK-004)

### RISK-003 — Confirmed Android bug (leadership-link taps silently no-op)
- **Independently re-confirmed this phase:** read `android/app/src/main/AndroidManifest.xml` directly — its only `<queries>` block is scoped to `android.intent.action.PROCESS_TEXT` (text-selection toolbar), not a browsable `http`/`https` `VIEW` intent. No change since the verifier phase.
- This is not a hypothetical or edge-case gap — it was reproduced live on an Android emulator (visualiser phase) and independently root-caused (verifier phase): tapping "Pope Leo XIV," "Bishop Vincent Long," or "Fr Gayan Thamel" produces no visible effect for a real user, with no error/crash to signal anything went wrong. It affects 3 of 29 requirements (REQ-F02-005/006/007).
- The fix is well-understood, narrow, and already documented: GitHub issue #12 specifies the exact `<intent>` block (`android.intent.action.VIEW` + `https` data scheme) to add to `android/app/src/main/AndroidManifest.xml`. It is a manifest-only change — no `lib/`/`test/` code changes required.
- **This agent did not apply the fix** — that would exceed the deployer role's scope (assessment/prep only, not code changes).

### RISK-004 — Unconfirmed iOS gap
- **Independently re-confirmed this phase:** read `ios/Runner/Info.plist` directly — no `LSApplicationQueriesSchemes` key exists. No iOS simulator/device run has been performed for this feature by any phase.
- Impact is assessed as lower-likelihood than RISK-003: `https` is a standard system URL scheme that `url_launcher`/`canLaunchUrl` typically does not require `LSApplicationQueriesSchemes` for (unlike custom app schemes), but this has not been positively confirmed by running the app on iOS. Given RISK-003 demonstrates this exact class of platform package-visibility gap is real for this dependency (not merely theoretical), it should not be assumed away.

### Recommendation (for the user to decide — not silently decided here)
Two reasonable paths exist; this note lays out the trade-off rather than picking one:

1. **Fix before merge (recommended for RISK-003):** Apply the 1-file `AndroidManifest.xml` fix from GitHub issue #12, then re-verify live on an Android emulator/device that all 3 leadership-link taps actually open an external browser, and close issue #12 before this PR merges. This is a small, low-risk, well-documented change directly affecting real user-facing correctness for 3 requirements — the kind of gap that is cheap to close now and more awkward to explain away later ("why does tapping the Pope's name do nothing?"). Recommended because the defect is confirmed (not speculative), the fix is narrow and already scoped, and shipping a known-broken tap target to real users when a same-day fix exists is a weak trade-off.
2. **Ship with RISK-003 tracked as a known issue, follow-up PR:** Merge this feature now with RISK-003 documented in the PR description (see PR readiness note) and issue #12 left open, to be fixed in a small, fast-follow PR. This mirrors how `01-bootstrap-app` handled its own conditional-pass risk (RISK-002), which was resolved during the Deployer phase rather than blocking merge — but that precedent involved a coverage gap (no live-run had been done yet), not a confirmed live defect. RISK-003 is a stronger case for fixing first, precisely because it is already confirmed broken, not merely unverified.

For RISK-004, since it is unconfirmed either way, the lower-cost path is: **ship with it tracked as a known risk**, and confirm/resolve it opportunistically the first time an iOS simulator/device becomes available in this workflow (no iOS run has occurred for this feature at all yet, so blocking merge on it would be disproportionate to its likelihood).

**This phase's local-readiness verdict does not itself block on either risk** — analyze/format/test/build are all clean and reproducible. The open question is a product/release judgment call (ship a known narrow bug vs. take a same-day fix first), which is explicitly left to the user.

## Rollback Notes

This feature is additive, UI/content-only, with no backend calls, no persistence, and no schema/data migration:
- New/changed surfaces: `lib/features/parish/` (real content replacing the `PlaceholderScreen` stub), `lib/app/shell/` (AppBar chrome — logo + 2 pills), `lib/shared/widgets/app_pill_button.dart`, `lib/features/ask_luke/` (new feature module), `lib/core/services/url_launcher_service.dart`, bundled assets under `assets/images/leadership/` and `assets/images/branding/`, new `url_launcher` dependency in `pubspec.yaml`.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; a subsequent feature branch cannot cleanly build against the new AppBar chrome or Ask Luke module.
- **Rollback procedure:**
  1. Preferred: `git revert <merge-commit-sha>` on `main` — self-contained, no data/backend side effects, safe as long as no later feature has already built directly on top of the new AppBar chrome (`lib/app/shell/`) or `UrlLauncherService` abstraction.
  2. If revert conflicts because later work already depends on the new shared chrome or `url_launcher` wiring: do not force-revert; fix forward instead (e.g. a targeted patch), since there is no functional defect in the *verified* 26/29 requirements — only the 3 flagged, narrow, well-understood RISK-003 gap.
  3. If only RISK-003/004 turn out to be worse than assessed post-merge (e.g. a crash rather than a silent no-op is discovered on some Android/iOS version): this does not require a full feature rollback — it is a manifest/plist-level fix, isolated from the rest of the feature's UI and content.
- No database, backend config, feature flags, or store listings are affected. No app-store submission has occurred for this feature — no store-side rollback (staged rollout halt, phased release pause) applies.

## Release Readiness Verdict

**Locally release-ready** (analyze/format/test/build all clean and independently reproduced this session). **Not yet "known-issue-free release-ready"** — RISK-003 is a confirmed, live, user-facing defect on Android affecting 3 requirements, and RISK-004 is an unconfirmed but plausible analog on iOS. Recommend the user decide between "fix RISK-003 before merge" (preferred, low cost, already scoped via issue #12) and "ship with RISK-003 tracked, fast-follow fix" before this proceeds to PR creation.
