Closes #24

## Feature
- Feature ID: 08
- Feature Name: ministries-api
- Branch: feature/08-ministries-api

## Summary
- **Scope:** the Ministries tab and detail screen now load from the parish API (`GET /v1/ministries`, falling back to `GET /v1/ministries/{id}` for ids missing from the list) instead of the hardcoded `static_ministries_config.dart`. The config is deleted.
- **User value:** staff can change ministries in the parish service's `/admin` console without an app release. Nothing changes on screen: the bundled snapshot was checked field-for-field against the old config (all 16 ministries, same order).

### How it behaves
| Situation | What the user sees |
|---|---|
| Online, first launch | Loading spinner, then the live list, which is saved on the device |
| Something saved | The saved list straight away, replaced when the background fetch succeeds |
| Saved list, fetch fails | The saved list stays; nothing is overwritten |
| Nothing saved, offline | `assets/ministries_fallback.json`, a snapshot of `GET /v1/ministries` |
| Pull down to refresh | Network only. On failure a SnackBar says the saved list is shown |
| Detail id not in the list | Fetched by id; a 404 shows the existing "Ministry not found." |

### Changes
- **Data layer:** `lib/features/ministries/{domain,data}`, following `features/news` and `features/saint_of_the_day`.
  - A remote datasource with a 10s timeout, UTF-8 decoding from the raw bytes, and an injectable header builder for a future `X-Firebase-AppCheck` header.
  - A strict JSON parser: missing or ill-typed fields fail with the field's path, and unknown fields are ignored.
  - Sealed `MinistriesFailure` types.
  - A `shared_preferences` cache that stores the raw response body.
  - A bundled-asset source.
  - A stale-while-revalidate repository.
- **Providers:** `ministriesRepositoryProvider`, a `Ministries` StreamNotifier with `refresh()`, and `ministryByIdProvider`. All are generated, with the `.g.dart` files committed.
- **Screens:** explicit loading, error+retry (48px target), empty and data states, plus `RefreshIndicator`.
- **Entity:** `Ministry` drops `emoji`, and `ctaEmail` becomes `contactEmail` + `emailSubject`. The CTA uses the issue's `Uri(scheme: 'mailto', query: 'subject=${Uri.encodeComponent(...)}')`, so spaces become `%20`, not `+`.
- **Config:**
  - `API_BASE_URL` (origin only) in `assets/app.env`, set to `https://parish-app-service.fly.dev`. When it's unset, the origin of `BASE_URL` is used.
  - It's validated with the same rules as `BASE_URL`: that logic moved from `NotificationService.resolveBackendUri` into `lib/core/config/backend_uri.dart`, which both now use.
  - A set but invalid `API_BASE_URL` doesn't silently fall back.
- **Ministry list layout (from hands-on review):** the 2-column grid of fixed-aspect cards was replaced with grouped list rows. Each category is one card with a row per ministry: name, a "members · day" line and a chevron.
  - Rows are about 64–80pt tall, down from about 210pt cards on a Pro Max.
  - Text uses `TextTheme` styles of 13pt and up, with AA contrast. Each row is one screen-reader button with a target of at least 48pt.
  - This fixes the **list** half of #26. `MinistryCard` is replaced by `MinistryRow` and `MinistryGroupCard`.
- **Docs:** CLAUDE.md now allows the parish API's public, read-only `GET /v1/*` (plus the existing `POST /tokens`) and forbids `/admin`. README has a "Parish API (Ministries)" section, including the command to refresh the snapshot at release time. ADR-0006 records the design.

## Risks
- **RISK-013 / #26 (pre-existing, found while testing):** on `main`, the Ministries grid overflows at 1.5x/2x system text size, and the detail header overflows at 1.0x for "Extraordinary Ministers of Holy Communion".
  - **List:** fixed in this PR by the compact rows. Every list state (loading, error, empty, data) now passes a 1.0x/1.5x/2.0x sweep.
  - **Detail screen:** header and stat chips are not changed here and remain open in #26.
- **RISK-012:** the bundled snapshot goes stale unless it's refreshed before each release (README > Parish API). `ministries_fallback_asset_test.dart` pins its contents, so a refresh shows up as a test diff to review.
- **Behaviour change:** content now comes from the parish API. If the API is down, users see the saved or bundled copy, not an error. The server's `Cache-Control: max-age=300` isn't honoured on the device, and ETag is out of scope per the issue.
- **Unchanged:** `BASE_URL` still holds the emulator URL. The existing opt-in release check still fails on it (feature 07). The new `API_BASE_URL` check passes.

## Tests
- **New:**
  - JSON parser: missing, ill-typed and unknown fields, and envelope errors.
  - Datasource (`MockClient`): URL, headers, injected headers, UTF-8, non-200, 404, timeout, transport error, no base.
  - Repository: cache then network, network fails and the cache stays, no cache and offline uses the fallback, corrupt cache, failed write, refresh, 404.
  - `shared_preferences` cache.
  - `API_BASE_URL` resolution.
  - Providers.
  - Mailto encoding edge cases.
  - Fallback asset: the 16/4 checks, now on the asset.
  - List and detail state widget tests, including pull-to-refresh and a text-scale sweep of the new states.
- **Updated:** `ministries_screen_test` and `ministry_detail_screen_test` are driven by a fake repository loaded from the fallback JSON. The emoji tests are removed, and the mailto expectations are now encoded, e.g. `mailto:marsdenpark@parracatholic.org?subject=Music%20Ministry%20Interest` and `mailto:sacraments@stlukesmarsdenpark.org.au?subject=Sacramental%20Programme%202026`.
- **Rows:** `ministry_row_test.dart` covers content, the dot left out when a part is empty, compact height, tap, merged button semantics and 2x wrapping. The list text-scale sweep now includes the data state.
- **Shell:** the six-tab chrome test overrides the ministries repository, so it stays offline.
- **Hands-on (user):** Ministries tab works on an iPhone 17 Pro Max simulator. The oversized cards it showed led to the compact rows above, and the user re-checked and approved the new rows.
- **On device:** a scripted smoke run on an iOS iPhone 17 simulator against the live API (not committed) passed. It covered fetch and save, detail, pull-to-refresh, offline with cache plus the SnackBar, and offline with no cache plus the bundled fallback. It wasn't a hands-on review, and Android wasn't run because this machine has no Android SDK.

## Artifacts
- BA Plan: `.claude/plans/ba/2026-10-08_10-51-08-ministries-api.md` (REQ-F08-001..022)
- Coder Plan: `.claude/plans/coder/2026-10-08_10-51-08-ministries-api.md`
- Tester Plan: `.claude/plans/tester/2026-10-08_10-51-08-ministries-api.md`
- App-Visualiser Plan: `.claude/plans/visualiser/2026-10-08_10-51-08-ministries-api.md`
- Verifier Plan: `.claude/plans/verifier/2026-10-08_10-51-08-ministries-api.md`
- Deployer Plan: `.claude/plans/deployer/2026-10-08_10-51-08-ministries-api.md`
- Verification Report: `.claude/verification/2026-10-08_10-51-08-ministries-api.md` (pass, with risks carried forward)
- Release Readiness: `.claude/releases/2026-10-08_10-51-08-ministries-api-release-readiness.md`
- ADR: `.claude/decisions/0006-ministries-from-parish-api.md`
- Risks: `.claude/risks/active-risks.md` (RISK-012, RISK-013)
- Latest Journal: `.claude/journal/2026-10-08_10-51-08-ministries-api-deployer.md`
- Memory: `.claude/memory.md`

## Validation
- Rebased with main: not needed (0 behind `origin/main` `aa91b85`)
- Merge conflicts resolved: n/a
- dart format: pass (`lib/` and `test/`, 0 changed)
- flutter analyze: pass (no issues)
- flutter test: pass (423 passed, 2 skipped; the skips are the opt-in `RELEASE_CHECK` tests)
- build validation: pass for iOS (`flutter build ios --no-codesign`, `Runner.app` 22.2MB). Android not built (no SDK on this machine).

## Approval
- User approval recorded: yes. The user approved one plan up front for a condensed SDLC (BA → deployer without per-phase stops), ending in this PR. Merging is manual.
