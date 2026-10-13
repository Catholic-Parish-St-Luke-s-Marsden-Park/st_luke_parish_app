# CODER_AGENT Plan

- Feature ID: 09
- Feature Slug: saint-of-the-day-api
- Branch: feature/09-saint-of-the-day-api (base HEAD `ce86670`, rebased on origin/main `6145462`)
- Phase: coder
- Timestamp: 2026-10-12_22-36
- BA plan: `.claude/plans/ba/2026-10-12_22-36-09-saint-of-the-day-api.md` (REQ-F09-001..023, D-1..D-8)

## Implementation

### Removed (D-1, REQ-F09-004)
- `lib/features/saint_of_the_day/data/datasources/openrouter_saint_datasource.dart`
- `lib/features/saint_of_the_day/data/parsers/saint_text_parser.dart`
- `test/features/saint_of_the_day/data/datasources/openrouter_saint_datasource_test.dart`
- `test/features/saint_of_the_day/data/parsers/saint_text_parser_test.dart`
- `sydneyFullDateForPrompt` and `sydneyDisplayDate` (no other caller; the display date now comes from the server) from `sydney_date.dart`.
- README "Saint of the Day (OpenRouter API key)" section. `grep -ri openrouter lib test README.md` returns nothing.

### Domain
- `failures/saint_of_the_day_failure.dart`: sealed `SaintOfTheDayFailure` with NotConfigured, Network, NotReady, DateUnavailable, Unavailable, Parsing (one per user-visible message).
- Entity and repository-contract doc comments updated; entity shape unchanged.

### Data
- `models/problem_details.dart` + `parsers/problem_details_parser.dart`: tolerant RFC 9457 reader (status, code, title, requestId); never throws, returns null for non-problem bodies.
- `datasources/saint_of_the_day_remote_datasource.dart`: `fetchSaintJson(dateKey)` -> `GET {base}/v1/saints/{dateKey}`. Mirrors `MinistriesRemoteDatasource` (10s timeout, Accept + User-Agent, UTF-8 from bodyBytes, `SaintRequestHeadersBuilder` hook that sends nothing by default). Null base -> NotConfigured before any request. Status/code mapping per REQ-F09-006; diagnostic message carries path, status, dateKey, code, requestId.
- `parsers/saint_json_parser.dart`: `parseSaintJson` (10 required string fields, named in failures; `dateKey` must be a real `YYYY-MM-DD` via `isWellFormedDateKey`; unknown fields ignored; mismatch with the requested key not checked).
- `repositories/saint_of_the_day_repository_impl.dart`: dateKey computed once from the injected clock -> cache read -> fetch -> parse -> empty-name / no-content guards (D-6) -> best-effort write under the server `dateKey` (D-7). Every failure logged once via `developer.log` (REQ-F09-007) and rethrown; cache untouched on failure.
- `sydney_date.dart`: only `sydneyNow` + `sydneyDateKey`; doc now states the exact DST mis-modelling window and why the date is unaffected.
- `cache/saint_of_the_day_cache.dart`: logic unchanged (D-2); doc comment only.

### Presentation
- `providers/saint_of_the_day_provider.dart`: repository built from `httpClientProvider` + `apiBaseUriProvider`; `.g.dart` regenerated with build_runner.
- `screens/saint_of_the_day_screen.dart`: `_messageFor` is an exhaustive switch over the sealed failure with the six REQ-F09-016 strings.
- `widgets/saint_of_the_day_error_view.dart`: root changed from `Padding` to `SingleChildScrollView` with the same padding. Needed because the new DateUnavailable message overflowed by 82px at 2.0x on a 360x690 phone; no visual change at normal sizes.

### Other
- `lib/app/provider_retry.dart`: comment no longer refers to OpenRouter.
- README: new "Saint of the Day (Parish API)" section; API endpoint list updated.
- ADR-0008 added; ADR-0005 status set to superseded.
- `.claude/risks/active-risks.md`: RISK-008 moved to Resolved with a resolution note; RISK-017 (= RISK-F09-002, device clock, accepted) and RISK-018 (= RISK-F09-003, App Check enforce, open) added.

## Tests (coder-phase coverage of REQ-F09-020..022)
- New: `data/saint_json_fixtures.dart`, `data/datasources/saint_of_the_day_remote_datasource_test.dart` (URL/headers, no `/today`, header hook, UTF-8, every REQ-F09-006 row, problem with/without requestId, non-JSON body, transport, header-builder failure, 10s timeout), `data/datasources/saint_of_the_day_live_test.dart` (live, skips on 503 `saint_not_ready`), `data/parsers/saint_json_parser_test.dart`, `data/parsers/problem_details_parser_test.dart`.
- Rewritten: `data/repositories/saint_of_the_day_repository_impl_test.dart` (same key for cache and request, hit/miss, server dateKey write, failed write, guards, failures leave cache untouched, midnight rollover), `data/sydney_date_test.dart` (midnight in AEST/AEDT, both DST windows, New Year).
- Extended: `presentation/providers/saint_of_the_day_provider_test.dart` (wiring through `apiBaseUriProvider`/`httpClientProvider`, no-base => NotConfigured with zero requests), `presentation/screens/saint_of_the_day_screen_test.dart` (exact text for all six failures + Try again >= 48px + no diagnostics leaked), `presentation/screens/saint_of_the_day_screen_text_scale_test.dart` (six failures x 1.0/1.5/2.0x).
- Kept unchanged: both cache tests.
- Comment-only: `test/app/shell/app_bar_chrome_test.dart`.

## Commands run
- `dart run build_runner build --delete-conflicting-outputs` — OK, only `saint_of_the_day_provider.g.dart` changed.
- `dart format .` — 200 files, 0 changed on final run.
- `flutter analyze` — No issues found.
- `flutter test` — 562 passed, 2 skipped (pre-existing opt-in release checks), 0 failed.
- `flutter test test/features/saint_of_the_day/data/datasources/saint_of_the_day_live_test.dart` — passed against production.

## Deviations / notes
- Error view scroll wrapper (above) is a layout-robustness fix required by REQ-F09-016, not a redesign.
- The content guard treats whitespace-only sections as empty (stricter than the screen's `isNotEmpty`), so a whitespace-only payload fails rather than rendering blank cards.
- Problem parsing lives in the saint feature (`data/parsers`), not `core/`: ministries does not parse problem bodies today, so there was no second caller to justify sharing it.
- Typedef named `SaintRequestHeadersBuilder` to avoid clashing with ministries' `RequestHeadersBuilder` if both are imported.

## Deferred
- Tester phase: full test design review, golden tests if wanted, RISK-007 tagging for the new live test.
- User: revoke/rotate the old OpenRouter key (RISK-F09-007).
- Server coordination for App Check enforce mode (RISK-018).
