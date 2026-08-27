# Release Readiness Note — 03-multi-pages

- Feature ID: 03
- Feature Slug: multi-pages
- Branch: feature/03-multi-pages
- Timestamp: 2026-08-27_22-22
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-08-27_22-20-03-multi-pages.md`). All 29 BA-approved requirements (REQ-F03-001..029) have complete, independently-verified code and test traceability — the condition on this pass is entirely risk-based, not implementation-based. No requirement is unimplemented or mis-tested.

This note assesses **local release readiness** (buildability, test health, tooling cleanliness) and gives explicit, clearly-separated disclosure of three open risks. **The user has already made the ship-vs-fix decision for all three** (ship with all three tracked, not fixed in this feature) — this note documents that decision accurately for release/PR visibility; it does not re-decide it.

## MOST IMPORTANT DISCLOSURE — READ FIRST: RISK-005 (production-breaking, not merely degraded)

**RISK-005 is materially more severe than RISK-003/RISK-004 below and must not be read as "just another item on the risk list."**

- **What's broken:** The release-build (`main`) Android manifest (`android/app/src/main/AndroidManifest.xml` — the manifest actually merged into any `flutter build apk --release`/`flutter build appbundle` output) has **no `android.permission.INTERNET` permission**. `webview_flutter`'s underlying `WebView` (used by the new Donate tab) cannot make any network request without it.
- **Concrete production impact:** Every real user who taps the Donate tab in a release/production build of this app will see a permanent "Unable to load this page" error state (`SimpleWebViewScreen`'s `_WebViewErrorState`) — the Donate feature will not work **at all**, for **100% of production users**, with no workaround. This is not a subset-of-taps degradation like RISK-003/004; it is a total feature failure in production.
- **Why it wasn't caught earlier:** `android/app/src/debug/AndroidManifest.xml` and `.../profile/AndroidManifest.xml` each independently carry their own dev-only `INTERNET` permission (explicitly commented as being for Flutter tooling/hot-reload). Every test/run so far — Coder's and Tester's `flutter test`, the Visualiser's live `flutter run -d emulator-5554` session ("everything looks good"), and this deployer phase's own `flutter build apk --debug` — used a debug or profile build, which masks the gap. **A debug build succeeding is not evidence against RISK-005.** Only a release-mode build (`flutter build apk --release` or `flutter run --release`) would reproduce it, and none has been run for this feature by any phase.
- **Independently re-confirmed this phase:** direct read of all three manifest variants this session, and `git diff --stat main..feature/03-multi-pages -- android/` confirms this feature's own commits did not touch any Android manifest file — RISK-005 is a **pre-existing** gap that this feature's new Donate WebView newly exposes as production-breaking, not a regression introduced by this feature's code.
- **Fix, if the user later reconsiders:** add a single `<uses-permission android:name="android.permission.INTERNET"/>` line to `android/app/src/main/AndroidManifest.xml`, then verify with a release-mode build that the Donate WebView loads the live page. Manifest-only; no `lib/`/`test/` changes required. Not applied by this agent, per the user's explicit decision to ship with it tracked.
- **User acknowledgement:** the user was explicitly told this is a genuine, confirmed, production-blocking bug (not a hypothetical edge case) before deciding to ship with it tracked rather than fixed in this feature (`.claude/memory.md`, 2026-08-27 entry). This note re-states that disclosure prominently so it is not missed by any later reader (reviewer, future self, or the user re-reading before final merge/store submission).

## Local Validation Evidence (independently re-run this session, 2026-08-27_22-22, fresh run on HEAD `4a52862`)

| Command | Result |
|---|---|
| `flutter --version` | Flutter 3.41.2 (stable), Dart 3.11.0 |
| `flutter pub get` | Succeeded — 31 packages have newer versions available within constraint; no forced upgrades |
| `flutter analyze` | `No issues found!` |
| `dart format . --set-exit-if-changed` | `Formatted 67 files (0 changed)`, exit 0 |
| `flutter test` | `All tests passed!` — 98/98, matches tester's and verifier's counts exactly |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` (note: this is a **debug** build and does **not** exercise or clear RISK-005 — see disclosure above) |

No release build (`flutter build apk --release`, `flutter build appbundle`, `flutter build ios --release`) was run in this session, consistent with prior features' deployer precedent. Note that unlike 01/02, running a release build here **would** be directly informative for RISK-005 specifically — it was not run because the user's decision was to ship with RISK-005 tracked rather than diagnosed further at this stage, not because it was assumed uninformative.

## Working Tree / Git State
- Current branch: `feature/03-multi-pages`, HEAD `4a52862`
- Working tree: clean except this phase's own new artifacts and the already-updated `.claude/memory.md` Active State header
- `git fetch origin main` re-run this session: branch is 5 commits ahead of `main`, **0 behind** — no rebase required (re-check again immediately before PR creation, since `main` could move before the PR is opened)
- No secrets, tokens, or credentials observed in this feature's changed files (`git diff --stat main..feature/03-multi-pages` reviewed)

## RISK-003 — Android `<queries>` gap (external `https:`/`tel:`/`mailto:` link taps silently no-op)
- **Independently re-confirmed this phase:** `android/app/src/main/AndroidManifest.xml`'s only `<queries>` block is scoped to `PROCESS_TEXT`, not a browsable `VIEW` intent for any scheme. Unchanged since 02-parish-tab's verifier phase.
- **Scope now wider than originally logged:** this feature adds the app's first `tel:`/`mailto:` launches (Ministries "Join Us" CTA is `mailto:`; Contact Phone/Mobile are `tel:`, Email is `mailto:`), in addition to more `https:` launches (Contact Facebook/Website/Google-Maps preview and pill). The originally-scoped fix (a `<queries>` block for `https` only, per GitHub issue #12) would not necessarily cover `tel:`/`mailto:` resolution — the eventual fix needs to cover all three schemes.
- **Impact:** Medium-high — degrades a subset of external-link taps (leadership links, Ministries CTA, several Contact tiles) on Android 11+, no crash, no visible feedback, silent no-op.
- **Status:** open, tracked via GitHub issue #12 (scope addendum needed).

## RISK-004 — iOS `LSApplicationQueriesSchemes` gap (unconfirmed)
- **Independently re-confirmed this phase:** `ios/Runner/Info.plist` has no `LSApplicationQueriesSchemes` key. No iOS simulator/device run has been performed for this feature by any phase.
- **Impact:** Low-medium, unconfirmed either way — `https`/`tel`/`mailto` are standard system schemes that typically don't require this key on iOS (unlike custom app schemes), but RISK-003 demonstrates this class of platform-configuration gap is real for this dependency on Android, so it isn't safely assumed away on iOS.
- **Status:** open, unconfirmed.

## Recommendation
This note does not re-decide the ship-vs-fix trade-off — the user has already made that call for all three risks (ship with all three tracked). For completeness and in case the decision is revisited before this branch is actually merged or before any store submission:

1. **RISK-005 is the one this agent would flag hardest for reconsideration**, if any of the three were to be fixed before merge: it is a one-line manifest change, it is release-build-certain (not probabilistic), and it fully breaks a shipped feature for every production user rather than degrading a subset of taps. The cost-to-fix vs. severity-if-shipped ratio is the most lopsided of the three risks.
2. RISK-003/004 remain reasonable to ship-and-track, consistent with how 02-parish-tab's analogous RISK-003/004 were ultimately handled (tracked in that PR, not blocked on).
3. Whichever path is chosen, none of these risks require a rollback of the feature itself post-merge — see Rollback Notes below.

## Store-Prep Consideration (not a formal store-metadata note — no listing content changes)
This feature does not touch any store-facing listing content (description, screenshots, keywords, age rating, privacy nutrition labels) — confirmed via inspection of this feature's diff, which is entirely `lib/`/`pubspec.yaml`/test changes. No `.claude/store-metadata/` note is produced, consistent with the "most features won't touch it" guidance.

One brief consideration worth carrying forward for whenever this app is actually submitted to app stores (not blocking for this PR):
- The new Donate tab is an in-app `WebView` pointed at an existing external page (`https://stlukesmarsdenpark.org.au/donate/`) that was already publicly reachable from the parish website before this feature. This does not introduce a new payment flow inside the app itself (no in-app purchase, no card entry inside the WebView is implemented by this app's own code) — it is a content WebView, not a native payment integration. App Store/Play Store reviewers occasionally scrutinize bare WebView wrappers around external content; if store submission is pursued later, it may be worth having a one-line justification ready (this is parish donation content sourced from the parish's own public website, not a novel or disguised payment mechanism). No action needed now.

## Rollback Notes

This feature is additive, UI/content-only for its Ministries/Contact/Donate surfaces, plus one shared bug fix in existing `core/` code (narrowed `UrlLauncherService` host-validation to allow `tel:`/`mailto:`, documented as ADR-0002) and one integration decision (bare-content `SimpleWebViewScreen`, ADR-0003). No backend calls, no persistence, no schema/data migration:

- New/changed surfaces: `lib/features/ministries/`, `lib/features/contact/`, `lib/features/donate/`, `lib/shared/webview/simple_webview_screen.dart`, `lib/shared/widgets/cta_pill_button.dart`, `lib/core/constants/external_links.dart`, a fix to `lib/core/services/url_launcher_service.dart` (ADR-0002), new `webview_flutter: ^4.14.1` dependency in `pubspec.yaml`.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; RISK-005 turns out to affect more than just the Donate tab post-merge (unlikely, since `INTERNET` is the only permission `webview_flutter` needs and no other network-dependent feature exists yet); a subsequent feature branch cannot cleanly build against the new `UrlLauncherService` host-validation change.
- **Rollback procedure:**
  1. Preferred: `git revert <merge-commit-sha>` on `main` — self-contained, no data/backend side effects, safe as long as no later feature branch has already built directly on top of `lib/shared/webview/` or the narrowed `UrlLauncherService` validation (ADR-0002).
  2. If revert conflicts because later work already depends on the shared WebView widget or the `tel`/`mailto` validation fix: do not force-revert; fix forward instead, since there is no functional defect in the 29 *verified* requirements — the open items are all platform-manifest/plist configuration gaps (RISK-003/004/005), not application-code defects.
  3. **RISK-005 specifically does not require a rollback if it turns out worse than assessed post-merge** — it is a one-line manifest addition to fix, isolated from the rest of this feature's UI and content, and can be patched forward in a fast-follow commit without touching `lib/`/`test/` code at all.
- No database, backend config, feature flags, or store listings are affected by this feature. No app-store submission has occurred — no store-side rollback (staged rollout halt, phased release pause) applies yet.

## Release Readiness Verdict

**Locally release-ready for a debug/internal build** (analyze/format/test/build all clean and independently reproduced this session, 98/98 tests passing). **Not release-ready for a production/store release build as-is** — RISK-005 would break the Donate tab for 100% of production users, and is a confirmed, not speculative, gap given direct manifest evidence. RISK-003/004 are lower-severity, ship-and-track-appropriate gaps affecting a subset of external-link taps. All three risks were disclosed to and explicitly accepted by the user prior to this phase; this note does not withhold or soften that disclosure, particularly for RISK-005.
