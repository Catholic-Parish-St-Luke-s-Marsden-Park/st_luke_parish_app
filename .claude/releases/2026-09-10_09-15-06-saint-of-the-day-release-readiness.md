# Release Readiness Note — 06-saint-of-the-day

- Feature ID: 06
- Feature Slug: saint-of-the-day
- Branch: feature/06-saint-of-the-day
- Timestamp: 2026-09-10_09-15
- Prepared by: DEPLOYER_AGENT

## Verdict Carried Forward
Verifier verdict: **CONDITIONAL PASS** (see `.claude/verification/2026-09-10_08-52-06-saint-of-the-day.md`). All 18 BA-approved requirements (REQ-F06-001..018) have complete, independently-verified code and test traceability. No requirement is unimplemented or mis-tested.

This note assesses **local release readiness** (buildability, test health, tooling cleanliness) and gives explicit, clearly-separated disclosure of the one open, feature-specific risk. **The user has already made the ship-vs-fix decision for RISK-008** (asked directly during this deployer phase) — this note documents that decision accurately for release/PR visibility; it does not re-decide it.

## MOST IMPORTANT DISCLOSURE FOR THIS FEATURE — READ FIRST: RISK-008

**RISK-008 is the risk that belongs to this feature specifically.**

- **What's the gap:** `OpenRouterSaintDatasource.fetchSaintText` (`lib/features/saint_of_the_day/data/datasources/openrouter_saint_datasource.dart:76-79`) converts *any* non-200 OpenRouter response — a bad/expired API key (401), rate limiting (429), a server error (5xx), or an actual connectivity failure — into the same `SaintOfTheDayNetworkFailure`, and the screen renders all of them as the identical "Unable to fetch today's saint. Please check your connection and try again." message.
- **How it was found:** not by testing — by a real incident during this feature's own visualiser phase. The user's first live run appeared to fail with exactly this message; the real cause (a literal placeholder API key string used verbatim instead of the real key, which OpenRouter correctly rejected with a 401) was indistinguishable from a genuine network problem until the underlying `flutter run` command was inspected directly.
- **Why it matters for production:** if the real OpenRouter key is ever revoked, expires, or the account runs out of credit, every user would see "check your connection" — a connectivity-sounding message for what is actually a configuration/billing problem that needs the parish team's attention, with no signal in the app itself that anything is misconfigured on the backend side.
- **Severity:** Medium, non-blocking. Low day-to-day likelihood (a working key that stays valid won't trigger this), but a plausible, foreseeable event given the accepted client-side key exposure trade-off already documented in ADR-0005.
- **This agent did not fix RISK-008:** per the user's explicit decision, made when directly asked during this deployer phase, RISK-008 is carried forward / shipped as-is rather than fixed in this feature. No `lib/`/`test/` code was modified in this deployer session.
- **Fix, if the user later wants to close it:** distinguish `401`/`403` from other non-2xx responses in `OpenRouterSaintDatasource.fetchSaintText` and surface a distinct, configuration-pointing failure type/message, without leaking the raw response body/key (REQ-F06-005 still applies). Small, scoped change confined to the datasource and the screen's `_messageFor` branch — recommended as a fast-follow.

## RISK-003 / RISK-004 / RISK-005 — pre-existing platform-configuration items, confirmed status for this feature

- **RISK-003 / RISK-004** (external-link manifest gaps) — **confirmed not applicable** to this feature. Independently re-confirmed both during the verifier phase and again this deployer phase: `grep` across `lib/features/saint_of_the_day/` for `url_launcher`/`UrlLauncher`/`webview_flutter`/`GestureDetector`/`InkWell`/`onTap` finds only the in-app "Try again" retry button, not an external link. Still open, unrelated, for the app overall.
- **RISK-005** (release-build Android `INTERNET` permission) — **confirmed applicable and already covered.** This feature is the app's third network-calling surface (a raw `POST` to `openrouter.ai`, same mechanism as News' RSS fetch). Independently re-read `android/app/src/main/AndroidManifest.xml` this session — the permission (fixed during 05-news-tab's deployer phase, unscoped by host) is present and already covers this feature. No manifest change needed or made.

## Local Validation Evidence (user-run, 2026-09-10, fresh session on HEAD `f0dd8d7`)

| Command | Result |
|---|---|
| `flutter --version` | Flutter 3.47.2 (stable), Dart 3.13.2 |
| `flutter pub get` | Succeeded — no forced upgrades, no dependency changes since coder phase |
| `flutter analyze` | `No issues found!` |
| `dart format . --set-exit-if-changed` | `Formatted 133 files (0 changed)`, exit 0 |
| `flutter test` | `232/232 passing` — matches tester's and verifier's counts exactly |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |

**Environment note, unlike every prior feature's deployer phase in this repo:** this cloud-side session has no Flutter SDK and no GitHub credentials, so both the Flutter validation above and the git/rebase check below were run by the user directly rather than independently re-run by this agent. Flagged as a methodology deviation, not hidden.

## Toolchain Observation (not a numbered risk)
The debug build surfaced two non-fatal Gradle deprecation warnings: Android Gradle Plugin 8.11.1 and Kotlin 2.2.20 will both eventually lose Flutter support (recommended minimums: AGP 9.0.1, Kotlin 2.3.20). These stem from this feature's own coder-phase toolchain setup (AGP 8.11.1 was deliberately chosen as Gradle wrapper 9.5.1's compatibility ceiling at the time) — pre-existing, not newly introduced by this deployer phase, and non-blocking today. Worth a toolchain refresh in a future feature before these become hard failures.

## Working Tree / Git State
- Current branch: `feature/06-saint-of-the-day`, HEAD `f0dd8d7`
- Working tree: clean except this phase's own new artifacts and the memory/feature-index updates
- User ran `git fetch origin main` this session (required interactive browser sign-in): `origin/main` is unchanged at `3e1b8da` (News-tab's PR #19 merge commit, same as the last cached fetch from 2026-08-30) — **0 commits behind, 6 ahead**. **No rebase required** (re-check again immediately before PR creation, since `main` could move before the PR is opened).
- `gh` CLI is **not installed** in the user's local PowerShell environment — confirmed this phase. Will need to be installed, or the PR opened manually via the GitHub web UI, at PR-agent time.
- This feature's diff touches `pubspec.yaml`/`pubspec.lock` (Riverpod 2.x->3.x + `shared_preferences`), `android/gradle.properties`/`android/gradle/wrapper/gradle-wrapper.properties` (Gradle 9.5.1), `analysis_options.yaml`, `README.md`, `.gitignore` — all carried over from the coder phase's toolchain setup, already reviewed and approved at that phase. **No `ios/` files touched** by this feature. No secrets, tokens, or credentials observed in the changed files.

## Store-Prep Consideration
This feature adds a new in-app screen reached from an existing home-shell pill; it does not touch any store-facing listing content (description, screenshots, keywords, age rating, privacy nutrition labels). The new outbound HTTPS call to `openrouter.ai` uses the Android `INTERNET` permission already declared and already disclosed for News' RSS fetch — no new store-reviewable permission or capability. No `.claude/store-metadata/` note is produced, consistent with the "most features won't touch it" guidance.

## Rollback Notes

This feature is largely additive (a new `lib/features/saint_of_the_day/` tree plus two small edits to existing pill/button widgets) but, unlike 04-masses-tab, **is not fully self-contained** — its commit history also carries the project-wide Flutter/Gradle/Riverpod toolchain bump (Riverpod 2.x -> 3.x, Gradle wrapper 9.5.1, `analyzer` 14.3.0) that was required to get any validation running at all this session, since the original coder-agent environment had no Flutter SDK.

- New/changed surfaces: `lib/features/saint_of_the_day/` (13 files, all directories), `lib/app/shell/widgets/saint_of_the_day_pill.dart`, `lib/shared/widgets/app_pill_button.dart`, `pubspec.yaml`/`pubspec.lock`, `android/gradle.properties`, `android/gradle/wrapper/gradle-wrapper.properties`, `analysis_options.yaml`, `.gitignore`, `README.md`, `.claude/decisions/0005-saint-of-the-day-direct-openrouter-call.md`, one pre-existing test file updated (`app_bar_chrome_test.dart`, superseding its old placeholder-dialog assertion per REQ-F02-017).
- **Rollback risk specific to this feature:** because this feature's commits include the Riverpod 3.x bump, a straightforward `git revert` of the merge commit is self-contained *today* (nothing else on `main` yet depends on Riverpod 3.x), but that safety window shrinks with every feature built on top of this one — a later revert attempt, once a subsequent feature branch has also adopted Riverpod 3.x APIs or the newer Gradle wrapper, would very likely conflict. Recommend treating this merge as a de facto toolchain-upgrade checkpoint: revert cleanly now if needed, but plan to fix-forward instead once later features have landed on top of it.
- **Rollback triggers:** `main` fails to build after merge; `flutter analyze`/`flutter test` regress on `main`; a subsequent feature branch cannot cleanly build against the new Riverpod 3.x baseline.
- **Rollback procedure:**
  1. Preferred (while this remains the newest merge on `main`): `git revert <merge-commit-sha>` — reverts the feature code, the pill/button wiring, and the toolchain bump together as one unit.
  2. If a real defect is found only in the feature's own code (not the toolchain bump): fix forward instead of reverting, since none of the 18 *verified* requirements have a known application-code defect — the only carried-forward item (RISK-008) is a messaging-clarity gap, not a functional failure.
  3. If revert conflicts because later work already depends on the Riverpod 3.x baseline: do not force-revert the toolchain portion; isolate and revert only this feature's own `lib/features/saint_of_the_day/`/pill-wiring changes instead, leaving the toolchain bump in place.
- No database, backend config, feature flags, or store listings are affected by this feature. No app-store submission has occurred — no store-side rollback applies yet.

## Release Readiness Verdict

**Locally release-ready for a debug/internal build** — analyze/format/test/build all clean, user-confirmed fresh this phase, 232/232 tests passing, matching tester and verifier exactly. This feature introduces no new production-breaking risk: RISK-003/004 are confirmed not applicable, RISK-005 is confirmed already covered. **The one feature-specific open item is RISK-008** (generic failure messaging) — genuine, surfaced by a real incident during the visualiser phase, but non-blocking, and the user has explicitly chosen to carry it forward rather than fix it in this phase. This note discloses it prominently and does not soften or withhold it.
