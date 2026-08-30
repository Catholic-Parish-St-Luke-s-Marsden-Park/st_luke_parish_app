# Release Readiness Note — 04-masses-tab

- Feature ID: 04
- Feature Slug: masses-tab
- Branch: feature/04-masses-tab
- Timestamp: 2026-08-30_17-00
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-08-30_16-05-04-masses-tab.md`). All 24 BA-approved requirements (REQ-F04-001..024) have complete, independently-verified code and test traceability — the condition on this pass is entirely risk-based, not implementation-based. No requirement is unimplemented or mis-tested.

This note assesses **local release readiness** (buildability, test health, tooling cleanliness) and gives explicit, clearly-separated disclosure of four open risks. **The user has already made the ship-vs-carry-forward decision for all four** (carry all four forward, not fix in this feature) — this note documents that decision accurately for release/PR visibility; it does not re-decide it.

## MOST IMPORTANT DISCLOSURE FOR THIS FEATURE — READ FIRST: RISK-006 (feature-specific, not a pre-existing platform gap)

**RISK-006 is the risk that belongs to this feature specifically. It is a different kind of gap from RISK-003/004/005 below (which are pre-existing platform-configuration gaps unrelated to Masses) and must be read on its own terms.**

- **What's unconfirmed:** No human has given specific pass/fail feedback on how the Masses tab actually *renders* on a device/simulator. The App-Visualiser phase (`.claude/plans/visualiser/2026-08-30_13-17-04-masses-tab.md`, `.claude/journal/2026-08-30_13-17-04-masses-tab-visualiser.md`) confirmed the app launched successfully on an iPhone 16e simulator with no exceptions in the launch log, and the user was given a 6-point manual-check checklist (hero without address subtitle, "What's On" sub-group order, 9 total rows across both sections, no icons/emoji, no tappable rows, weekday+time-only rows) — but the user moved directly to requesting the Verifier agent without reporting specific pass/fail results against that checklist.
- **What automated tests do and don't cover:** `test/features/masses/masses_screen_test.dart` includes a thorough 9-combination screen-size × `TextScaler` (1.0/1.5/2.0) overflow sweep, which confirms no Flutter *exception*-raising layout failure occurs. It cannot confirm legibility, visual spacing, or whether specific longer strings wrap in a way that reads well to a human — in particular the two longest strings in this feature's content, **"Marsden Park Care Community Mass"** and **"Reconciliation from 4:30–5:25pm"**, have not been confirmed by a human to wrap cleanly at default or increased system text size on a real rendering engine.
- **Why this is lower severity than it might sound:** this feature has no network calls, no external links, no tappable rows, and no platform-channel code (independently re-confirmed this phase via `grep` across `lib/features/masses/` for `url_launcher`/`webview`/`InkWell`/`GestureDetector`/`onTap` — zero matches). The worst-case outcome of RISK-006 being real is a cosmetic wrapping/spacing issue, not a functional failure, crash, or silent no-op like RISK-003/005.
- **This agent did not close RISK-006:** per the user's explicit instruction during the verifier phase, RISK-006 was carried forward to Deployer rather than closed with a targeted visual check first (mirroring how RISK-003/004/005 were carried forward through 03-multi-pages' Deployer phase without a fix). This deployer session did **not** run the app live on a simulator/device to check RISK-006 itself — it is being disclosed here, not resolved.
- **Fix, if the user later wants to close it:** run the app on an iOS or Android simulator/device and visually confirm the Masses tab against the visualiser's original 6-point checklist, paying particular attention to the two longer strings at default and 1.5x/2.0x system text scale. No code change is anticipated to be needed unless a real wrapping/spacing defect is found.

## RISK-003 / RISK-004 / RISK-005 — pre-existing platform-configuration gaps, confirmed NOT applicable to this feature's own code

These three risks were logged during 02-parish-tab and 03-multi-pages, are unrelated to Masses, and remain open in the app overall (not resolved by this or any feature since). Independently re-confirmed this phase, both by direct manifest/plist re-read and by `git diff --stat main...feature/04-masses-tab` (this feature's own commits touch **no** `android/` files and only two auto-generated `ios/` files — `ios/Podfile.lock`, `ios/Runner.xcodeproj/project.pbxproj`, CocoaPods/Xcode bookkeeping from a coder-phase simulator run, not `ios/Runner/Info.plist` itself, which is untouched):

- **RISK-003** — `android/app/src/main/AndroidManifest.xml` still has only a `PROCESS_TEXT` `<queries>` block, no browsable `VIEW`/`tel`/`mailto` intent declarations. **Not applicable to Masses** — this feature has zero external links or tappable rows. Still open for the app overall (leadership links, Ministries CTA, Contact tiles from earlier features). Tracked via GitHub issue #12.
- **RISK-004** — `ios/Runner/Info.plist` still has no `LSApplicationQueriesSchemes` key. **Not applicable to Masses**, same reasoning as RISK-003. Still open, unconfirmed, for the app overall.
- **RISK-005** — release-build (`main`) `AndroidManifest.xml` still has no `android.permission.INTERNET` entry (only `debug`/`profile` manifests carry it). **Not applicable to Masses** — this feature makes no network calls and includes no WebView. Still open, still production-breaking for the Donate tab (03-multi-pages) specifically, unrelated to this feature.

None of RISK-003/004/005 are newly introduced, worsened, or touched by this feature's commits. They are restated here only for completeness and because the user asked for accurate disclosure of their current status as part of this phase, not because Masses implicates them.

## Local Validation Evidence (independently re-run this session, 2026-08-30_17-00, fresh run on HEAD `ecff7eb`)

| Command | Result |
|---|---|
| `flutter --version` | Flutter 3.41.2 (stable), Dart 3.11.0 |
| `flutter pub get` | Succeeded — 46 packages have newer versions within constraint; no forced upgrades; `pubspec.yaml`/`pubspec.lock` unchanged by this feature |
| `flutter analyze` | `No issues found!` |
| `dart format . --set-exit-if-changed` | `Formatted 81 files (0 changed)`, exit 0 |
| `flutter test` | `All tests passed!` — 123/123, matches tester's and verifier's counts exactly |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |

No release build (`flutter build apk --release`, `flutter build appbundle`, `flutter build ios --release`) was run in this session, consistent with prior features' deployer precedent. Unlike 03-multi-pages, a release build would not be specially informative here — this feature has no network dependency that RISK-005 would affect, so a release build would not exercise anything a debug build doesn't already cover for Masses specifically.

## Working Tree / Git State
- Current branch: `feature/04-masses-tab`, HEAD `ecff7eb`
- Working tree: clean except this phase's own new artifacts and the memory/feature-index updates
- `git fetch origin main` re-run this session: branch is 7 commits ahead of `origin/main`, **0 behind** — no rebase required (re-check again immediately before PR creation, since `main` could move before the PR is opened)
- `gh pr list`: no open PRs currently exist for this or any feature
- No secrets, tokens, or credentials observed in this feature's changed files (`git diff --stat main...feature/04-masses-tab` reviewed — all changes are `.claude/` docs, `lib/features/masses/`, `test/features/masses/`, one test-file fix, and the two auto-generated `ios/` CocoaPods files noted above)

## Store-Prep Consideration
This feature does not touch any store-facing listing content (description, screenshots, keywords, age rating, privacy nutrition labels) and adds no new capability a reviewer would scrutinize (no WebView, no external link, no new permission, no network call). No `.claude/store-metadata/` note is produced, consistent with the "most features won't touch it" guidance. No app-review consideration beyond that carried over from 03-multi-pages' Donate WebView (unrelated to this feature) is warranted.

## Rollback Notes

This feature is additive and self-contained: it replaces only the Masses tab's `PlaceholderScreen` stub with static, typed content. No repository/datasource/scraper layer, no network calls, no persistence, no schema/data migration, no shared/core code changes:

- New/changed surfaces: `lib/features/masses/domain/entities/{mass_time,mass_sub_group,mass_schedule}.dart`, `lib/features/masses/data/config/static_mass_schedule_config.dart`, `lib/features/masses/presentation/providers/mass_schedule_provider.dart` (+ generated `.g.dart`), `lib/features/masses/presentation/screens/masses_screen.dart`, five new presentation widgets under `lib/features/masses/presentation/widgets/`. One incidental fix to `test/features/placeholder_screens_test.dart` (removed the now-obsolete `MassesScreen` case from the shared placeholder table). No `lib/core/`, `lib/shared/`, `lib/app/`, `android/`, or `pubspec.yaml`/`pubspec.lock` changes.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; a subsequent feature branch cannot cleanly build against the new `massScheduleProvider` or Masses widget set (unlikely — nothing else in the app currently depends on `lib/features/masses/`).
- **Rollback procedure:**
  1. Preferred: `git revert <merge-commit-sha>` on `main` — self-contained, no data/backend side effects, no shared/core code touched, safe as long as no later feature branch has already built on top of `lib/features/masses/`'s public surface (unlikely for the next feature, News, which is a separate tab).
  2. If revert conflicts because later work already depends on this feature's widgets/provider pattern: do not force-revert; fix forward instead, since there is no functional defect in the 24 *verified* requirements — the only open item (RISK-006) is an unconfirmed live-render check, not a known application-code defect.
  3. RISK-006 specifically does not require a rollback if a real defect is later found — it would most likely be a text-wrapping/spacing fix isolated to one or two widget files (`mass_row.dart`, `masses_hero_banner.dart`), patchable forward in a fast-follow commit.
- No database, backend config, feature flags, or store listings are affected by this feature. No app-store submission has occurred — no store-side rollback applies yet.

## Release Readiness Verdict

**Locally release-ready for a debug/internal build** (analyze/format/test/build all clean and independently reproduced this session, 123/123 tests passing, matching tester and verifier exactly). This feature introduces no new production-breaking risk of its own — RISK-003/004/005 are pre-existing, confirmed not applicable to Masses, and untouched by this feature's commits. **The one feature-specific open item is RISK-006** (unconfirmed human live-render sign-off) — genuine but lower-severity than RISK-005 was for 03-multi-pages, since the worst case is a cosmetic wrapping/spacing issue, not a functional failure, and this feature has no network/external-link surface at all. All four risks were disclosed to the user prior to this phase (RISK-003/004/005 during earlier features, RISK-006 during this feature's verifier phase); this note does not withhold or soften any of them.
