# Release Readiness Note — 05-news-tab

- Feature ID: 05
- Feature Slug: news-tab
- Branch: feature/05-news-tab
- Timestamp: 2026-08-30_20-23
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-08-30_21-45-05-news-tab.md`). All 38 BA-approved requirements (REQ-F05-001..038) have complete, independently-verified code and test traceability — the condition on this pass is entirely risk-based, not implementation-based. No requirement is unimplemented or mis-tested.

This note assesses **local release readiness** (buildability, test health, tooling cleanliness) and gives explicit, clearly-separated disclosure of four open risks touching this feature. **RISK-005 is given first-read priority in this note** because this session's independent review found its severity has materially grown specifically for this feature — read it before RISK-003/004/007.

## RESOLVED — RISK-005 fixed post-deployer, before PR

The user reviewed the fix-now-vs-ship-and-track choice below and explicitly chose **fix now**, given the severity for this feature (would have broken the News tab's primary content, not an ancillary WebView). Added `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`. Verified with a real `flutter build apk --release` (succeeded, 53.2MB) and confirmed via `aapt dump permissions` on the built APK that the permission is genuinely present in the shipped manifest, not just the source XML. Re-ran `flutter analyze`/`dart format . --set-exit-if-changed`/`flutter test` after the change — clean, 175/175, no regressions. Marked Resolved in `.claude/risks/active-risks.md`. The analysis below is left intact as the record of the decision that was made, not as an open item.

## READ FIRST (historical) — RISK-005: release-build Android is missing `INTERNET`, and for News this is no longer a secondary-tab problem

**This is the most important disclosure in this note. Unlike for 03-multi-pages and 04-masses-tab, this is not a "restate an unrelated pre-existing gap" item — it now directly determines whether this feature's headline content works at all in production.**

- **What's confirmed, independently, this session:** `android/app/src/main/AndroidManifest.xml` — the manifest that is actually merged into release builds — has no `<uses-permission android:name="android.permission.INTERNET"/>` entry. Only `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` carry it, each explicitly commented as a Flutter-tooling/hot-reload convenience, not a production permission. `android/app/build.gradle.kts` has no manifest-merger override that would inject it into `main`.
- **Why this feature raises the stakes:** every feature before this one that needed network access (Donate) went through a `WebView`, which is one tab among several. **News is the app's first feature to make its own outbound `http.Client` request** (`lib/features/news/data/datasources/bulletins_feed_datasource.dart:24-44`, a GET to `https://stlukesmarsdenpark.org.au/category/bulletins/feed/`) as the mechanism for its **primary content section** — "Latest Bulletins" is not an ancillary feature of the News tab, it is most of the tab. Without `INTERNET` in the release manifest, this fetch will fail with a network error on every production Android install, and the tab will permanently show `BulletinsMessageView`'s network-failure state (`"Couldn't connect to load the latest bulletins. Check your connection and try again later."`) instead of any bulletin content, for 100% of production users, on top of the Donate tab already failing the same way.
- **Why it hasn't been caught by any prior phase:** identical reason as before — `flutter run`, `flutter test`, and every simulator/emulator run to date use debug or profile builds, each of which independently carries its own dev-only `INTERNET` permission that masks this exact gap. This was independently re-confirmed again this session: the debug APK built in this phase (`flutter build apk --debug`) would **not** exhibit this failure, because it uses the debug manifest, not the release one.
- **This agent's assessment, not a decision:** given that RISK-005 would now break this feature's core content (not just an ancillary WebView), the user has two genuine options for this feature, both legitimate:
  1. **Ship and track (prior precedent)** — merge as-is, carry RISK-005 forward exactly as was done for 03-multi-pages and 04-masses-tab, and fix it in a dedicated follow-up before any actual release build is produced/submitted. This is consistent with what has already been decided twice before, and the fix itself remains trivial (one manifest line) whenever it happens.
  2. **Fix now, before merge** — since the fix is a single-line, manifest-only change (`<uses-permission android:name="android.permission.INTERNET"/>` added to `android/app/src/main/AndroidManifest.xml`) with no `lib/`/`test/` code impact, and since this feature is the first to make the gap's consequence severe enough to break a tab's primary content rather than a secondary one, the user may reasonably prefer to close it now rather than carry it a third time.
  - **This agent does not choose between these two options.** No manifest edit has been made by this agent in this session. The decision is presented here for the user to make explicitly, alongside the standard "ship and track" precedent from prior features.
- **Fix, if the user chooses option 2:** add the single `<uses-permission>` line to `android/app/src/main/AndroidManifest.xml`, then verify with `flutter build apk --release` (or `flutter run --release`) that both the Donate WebView and the News bulletins fetch load live content. No `lib/`/`test/` changes required either way.

## RISK-003 / RISK-004 — pre-existing external-link platform-configuration gaps, now confirmed to also cover this feature's 3 new tap targets

- **RISK-003 (Android `<queries>` gap, GitHub issue #12):** `android/app/src/main/AndroidManifest.xml` still has only a `PROCESS_TEXT` `<queries>` entry — no browsable `https`/`tel`/`mailto` intent declarations. Independently re-confirmed unchanged this session. This feature adds 3 new `https:`-scheme tap targets that would be affected if this ships unresolved: the bulletin "Download PDF ↗" link (`lib/features/news/presentation/widgets/bulletin_list_tile.dart:71-73`), the bulletins-archive fallback link on empty/error states (`lib/features/news/presentation/widgets/bulletins_message_view.dart:32-34`), and the "Submit Prayer Request ↗" CTA (`lib/features/news/presentation/widgets/prayer_intentions_section.dart:44-46`). Same root cause and fix as already tracked for 02/03/04's links — no new risk class, only a growing surface area (now 12 tap targets total across 4 features). Not touched, worsened, or fixed by this feature's own commits (`git diff --stat main...feature/05-news-tab -- android/` is empty).
- **RISK-004 (iOS `Info.plist` `LSApplicationQueriesSchemes` gap):** `ios/Runner/Info.plist` still has no `LSApplicationQueriesSchemes` key. Independently re-confirmed unchanged this session. Notably, **this feature's own Visualiser phase already live-tested all 3 of its new tap targets on iOS Simulator and the user explicitly confirmed all worked** — the strongest positive on-device evidence any feature has produced for this risk category so far. This does not fully close RISK-004 project-wide (a working simulator run for 3 taps is not equivalent to positively confirming `Info.plist` requirements for every scheme in use, though plain `https` links typically do not require `LSApplicationQueriesSchemes` on iOS in the first place — which is exactly what makes this risk lower-priority than RISK-003/RISK-005). Not touched, worsened, or fixed by this feature's own commits (`git diff --stat main...feature/05-news-tab -- ios/` is empty).

Neither RISK-003 nor RISK-004 is newly introduced by this feature's code — they are pre-existing platform-configuration gaps whose scope this feature's new links simply extend. This restates, not re-decides, the ship-vs-fix precedent already set across 02-parish-tab/03-multi-pages/04-masses-tab.

## RISK-007 — live RSS tests are not isolated for offline/CI runs (new, logged this feature's verifier phase)

- **What's confirmed, independently, this session:** `test/features/news/data/datasources/bulletins_feed_live_test.dart` contains 2 ordinary `test()` blocks making real network calls against the live feed, with no `@Tags`, `skip:` parameter, or runtime connectivity guard. `find . -iname "dart_test.yaml"` — no file exists anywhere in this repo; there is no test-tagging convention to exclude these from a routine `flutter test` run.
- **Impact:** if `flutter test` is ever run in a fully offline or sandboxed CI environment, these 2 tests will report as **failures**, indistinguishable from a genuine regression, to anyone reading the output cold. This has not happened yet — every session to date (Coder, Tester, Verifier, this Deployer phase) has had network access, and both live tests were independently re-run and passed again this session.
- **This is a project-wide test-infrastructure gap, not a per-feature code defect**, and not something this agent's scope covers fixing (it would require introducing this repo's first `dart_test.yaml` tagging convention). Recommended before this app's first CI pipeline is stood up, or before any future feature adds more live-network tests.

## Local Validation Evidence (independently re-run this session, 2026-08-30_20-23, fresh run on HEAD `f21c9ca`)

| Command | Result |
|---|---|
| `flutter --version` | Flutter 3.41.2 (stable), Dart 3.11.0 |
| `flutter pub get` | Succeeded — 47 packages have newer versions within constraint; no forced upgrades; no dependency changes by this feature beyond `http`/`xml` already committed |
| `flutter analyze` | `No issues found!` |
| `dart format . --set-exit-if-changed` | `Formatted 109 files (0 changed)`, exit 0 |
| `flutter test` | `All tests passed!` — 175/175, matches tester's and verifier's counts exactly, including both live RSS tests against the real feed with network reachable this session |
| `flutter test test/features/news/data/datasources/bulletins_feed_live_test.dart` (isolated) | Both live tests passed independently, real network |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |

No release build (`flutter build apk --release`, `flutter build appbundle`, `flutter build ios --release`) was run in this session, consistent with prior features' deployer precedent. Note this means the RISK-005 failure mode described above was **not** directly reproduced with a release build in this session — its existence is established by direct manifest inspection (main manifest has no `INTERNET`; only debug/profile do), which is conclusive on its own, not by an actual failed release-build network call.

## Working Tree / Git State
- Current branch: `feature/05-news-tab`, HEAD `f21c9ca`
- Working tree: clean except this phase's own new artifacts (this file, the deployer plan, PR readiness note, journal, memory update)
- `git fetch origin main` re-run this session: `git rev-list --left-right --count origin/main...feature/05-news-tab` → `0  6` (0 commits only in `origin/main`, 6 only in this branch) — **0 behind, no rebase needed**
- **Rebase-check detail (per explicit task instruction, since main moved due to 04-masses-tab merging):** `git merge-base feature/05-news-tab origin/main` = `84decbe`, which is exactly `git rev-parse origin/main`'s current value. This confirms `feature/05-news-tab` already contains 04-masses-tab's merge (PR #18) at its base — main having moved does **not** require a rebase here because this branch already incorporates that move. Re-check again immediately before PR creation, since `main` could move further before the PR is opened.
- `gh pr list`: no open PRs currently exist for this or any feature
- No secrets, tokens, or credentials observed in this feature's changed files
- `git diff --stat main...feature/05-news-tab -- android/ ios/` is empty — this feature touches no `android/`/`ios/` files at all (a cleaner diff than 04-masses-tab, which had 2 auto-generated CocoaPods files)

## Store-Prep Consideration
This feature does not touch any store-facing listing content (description, screenshots, keywords, age rating, privacy nutrition labels). It does introduce this app's first feature-owned outbound network call (raw `http.Client` GET to the parish RSS feed, in addition to the existing Donate WebView's network use), but this does not change the Android/iOS permission model in a store-review-relevant way — `INTERNET` is a normal-protection-level Android permission requiring no user-facing consent dialog or store privacy-label declaration change, and iOS has no equivalent explicit permission for standard HTTPS requests. No `.claude/store-metadata/` note is produced, consistent with the "most features won't touch it" guidance.

## Rollback Notes

This feature is additive and mostly self-contained: it replaces the News tab's `PlaceholderScreen` stub with bulletin-feed content, static announcements, and a Prayer Intentions section. It adds one new core-shared file (`lib/core/network/http_client_provider.dart`) and one new shared constants file (`lib/core/constants/external_links.dart`), both scoped narrowly and reusable by future features, but does not modify any existing shared/core file.

- New/changed surfaces: `lib/features/news/` (domain/data/presentation, 18 files), `lib/core/network/http_client_provider.dart`, `lib/core/constants/external_links.dart`, `pubspec.yaml`/`pubspec.lock` (adds `http: ^1.2.2`, `xml: ^6.5.0`), `.claude/decisions/0004-news-rss-regex-vs-css-selector.md`. One incidental edit to `test/features/placeholder_screens_test.dart` (removed the now-obsolete `NewsScreen` case). No `android/`, `ios/`, `lib/app/`, or other existing `lib/shared/`/`lib/core/` file changes.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; the live RSS feed's structure changes in a way the regex/fallback chain (ADR-0004) cannot handle, causing persistent parsing failures in production (would surface as the "Couldn't load the latest bulletins" UI state, not a crash); a subsequent feature branch conflicts with `lib/core/network/http_client_provider.dart` or `lib/core/constants/external_links.dart`'s public surface.
- **Rollback procedure:**
  1. Preferred: `git revert <merge-commit-sha>` on `main` — self-contained feature module, no data/backend side effects, no destructive schema/migration. Two new `lib/core/` files are additive-only (nothing else in the app currently imports them outside `lib/features/news/`), so a revert should be clean unless a later feature branch has already built on top of them.
  2. If a real defect is found in the RSS regex/parsing logic specifically (not a manifest/permission issue): does not require a full revert — patchable forward in `lib/features/news/data/parsers/rss_bulletin_parser.dart` alone, isolated from the rest of the app.
  3. If RISK-005 is the cause of a production failure report (bulletins/Donate not loading): the fix is the single manifest line described above, not a code revert.
- No database, backend config, feature flags, or store listings are affected by this feature. No app-store submission has occurred — no store-side rollback applies yet.

## Release Readiness Verdict

**Locally release-ready for a debug/internal build** — analyze/format/test/build all clean and independently reproduced this session, 175/175 tests passing (including both live RSS tests against the real feed), matching tester and verifier exactly. All 38 requirements are fully implemented with complete, independently-verified traceability; no application-code defect is open.

**Confirmed release-ready for a production release build for the RISK-005 dimension specifically** — the user chose to fix it now rather than ship-and-track; the fix is applied, and independently verified in a real built release APK via `aapt`. RISK-003/RISK-004 remain open, pre-existing, lower-priority platform-configuration gaps whose scope this feature extends but does not worsen in kind — carried forward per the established 02/03/04 precedent, not re-decided here. RISK-007 is a test-infrastructure gap with no production impact. None of these are implementation defects in this feature's own delivered code — the verifier's conditional pass and this note's local-validation evidence both hold.
