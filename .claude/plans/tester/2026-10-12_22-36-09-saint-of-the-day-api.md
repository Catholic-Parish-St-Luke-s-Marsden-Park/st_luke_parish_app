# TESTER_AGENT Plan

- Feature ID: 09
- Feature Slug: saint-of-the-day-api
- Branch: feature/09-saint-of-the-day-api (HEAD `c9e1373`, rebased on origin/main `6ef2edd`; clean tree confirmed before starting)
- Phase: tester
- Timestamp: 2026-10-12_23-25
- Inputs: BA plan `.claude/plans/ba/2026-10-12_22-36-09-saint-of-the-day-api.md` (REQ-F09-001..023, D-1..D-8, RISK-F09-001..008), coder plan and journal (same timestamp), ADR-0008, root `CLAUDE.md`, `.claude/memory.md`. The post-coder 404 tightening was also in scope: only 404 `saint_not_available` maps to DateUnavailable.
- Status: complete, awaiting user approval

## Approach
1. I read every `lib/features/saint_of_the_day/**` file and every coder test directly, and checked them against each BA acceptance criterion and against CLAUDE.md's required states.
2. I added tests only where the coder suite had gaps, and changed no lib code.
3. I made the live tests skippable with a repo-wide `live` tag (RISK-007 / RISK-F09-008).

## Tests added or changed (+48 tests; 563 -> 611 passing)

| File | Change | Added cases |
|---|---|---|
| `test/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource_test.dart` | extended (+14) | Exactly `{Accept, User-Agent}` are sent by default, with no App Check header. A hook returning an empty map adds nothing. A trailing-slash base still requests `/v1/saints/{key}`. A 200 body is returned verbatim. `saint_not_ready` on a 404 is Unavailable. `saint_not_available` on a 503 is Unavailable. A 503 `saint_not_ready` with plain `application/json` is NotReady. Malformed problem bodies on a 503 (ill-typed code, truncated JSON, array, `null`) map by status alone (x4). A non-UTF-8 error body doesn't crash. A 404 `saint_not_available` diagnostic carries the requestId and dateKey. A timeout message names the dateKey and path. |
| `test/features/saint_of_the_day/data/parsers/saint_json_parser_test.dart` | extended (+9) | A top-level JSON `null`, string or number is a failure (x3). An empty body is a failure. A dateKey with surrounding whitespace or a trailing newline is rejected (x3). All-empty non-key fields are a valid shape, because the guard lives in the repository. Non-ASCII text is preserved. |
| `test/features/saint_of_the_day/data/sydney_date_test.dart` | extended (+3) | DST switches where the 1st of the month is the first Sunday: October 2028 and April 2029. That is the zero-offset branch of `_firstSundayOfMonthUtc`. Leap day 2028 at Sydney midnight. |
| `test/features/saint_of_the_day/data/repositories/saint_of_the_day_repository_integration_test.dart` | **new** (15) | Repository wired to the real datasource on a `MockClient`, the real shared_preferences cache, and a clock built as `sydneyNow(fixedUtc)`, as in production. Cases: <br>- cold start stores under the server dateKey; <br>- a stored same-key entry gives zero requests (the read key equals the request key); <br>- a corrupt entry is a miss, re-fetched and replaced; <br>- yesterday's entry is a miss and is replaced; <br>- 8 failure kinds (503 not ready, 404 not available, 401, transport, non-UTF-8 200, missing field, empty name, malformed dateKey) each leave the prefs byte-for-byte unchanged; <br>- a throwing platform write doesn't fail the read, and the next load re-requests; <br>- the AEDT midnight rollover at 13:00 UTC requests the new key and replaces the entry; <br>- a server dateKey that differs from the requested key is stored under the server key, so the next load requests again (RISK-F09-006 documented cost). |
| `test/features/saint_of_the_day/presentation/screens/saint_of_the_day_screen_test.dart` | extended (+4) | The header shows the server displayDate (`SEPTEMBER 1`). A full saint with an empty saying shows the other 5 section labels and hides Famous Saying. Try again re-runs the load (NotReady, then success shows the saint). A non-`SaintOfTheDayFailure` error shows the generic message and does not leak its text. |
| `test/features/saint_of_the_day/presentation/providers/saint_of_the_day_provider_test.dart` | extended (+3) | Real provider wiring sends only `{Accept, User-Agent}`. Invalidating after a success is served from the on-device cache with 1 request in total. An invalid `API_BASE_URL` (`resolveApiBaseUri('not a url')` gives null) produces NotConfigured with zero requests. |
| `dart_test.yaml` | **new** | Declares the `live` tag. |
| `test/features/news/data/datasources/bulletins_feed_live_test.dart`, `test/features/events/data/datasources/parish_events_feed_live_test.dart`, `test/features/saint_of_the_day/data/datasources/saint_of_the_day_live_test.dart` | header only | `@Tags(['live'])` plus `library;`. Test bodies are unchanged. |

### Live-test tagging decision (RISK-007, RISK-F09-008)
- The repo has exactly 3 real-network test files. All 3 are now tagged `live`, so the convention is applied consistently.
- `flutter test` still runs them by default. This keeps the current behaviour and CLAUDE.md's expectation of live verification.
  - Offline: `flutter test --exclude-tags live`.
  - Live only: `flutter test --tags live`.
- I did not exclude them by default. That would change what a plain `flutter test` proves, which is the user's call. RISK-007 is updated to "open, partly mitigated" with that decision recorded.
- CI (`ios-testflight.yml`) runs only `test/release_readiness_test.dart`, so CI is unaffected.

## Requirement -> test traceability

Paths are relative to `test/features/saint_of_the_day/`. Key: DS = `data/datasources/saint_of_the_day_remote_datasource_test.dart`, JP = `data/parsers/saint_json_parser_test.dart`, PP = `data/parsers/problem_details_parser_test.dart`, RU = `data/repositories/saint_of_the_day_repository_impl_test.dart`, RI = `data/repositories/saint_of_the_day_repository_integration_test.dart` (new), CA = `data/cache/*` (both cache tests), SD = `data/sydney_date_test.dart`, PR = `presentation/providers/saint_of_the_day_provider_test.dart`, SC = `presentation/screens/saint_of_the_day_screen_test.dart`, TS = `presentation/screens/saint_of_the_day_screen_text_scale_test.dart`, LV = `data/datasources/saint_of_the_day_live_test.dart`. (T) marks a tester-added case.

| REQ | Acceptance criterion | Covered by | Status |
|---|---|---|---|
| REQ-F09-001 | GET `{apiBase}/v1/saints/{dateKey}`, key computed once, 10s timeout, Accept + UA, UTF-8 from bytes, never `/today`/`/admin` | DS: URL+headers, never `/today`, UTF-8 without charset, 10s timeout (fake clock), trailing-slash base (T), timeout message (T). RU: same key for read and request. RI: path asserted end-to-end (T). PR: request via `apiBaseUriProvider`/`httpClientProvider`. `/admin` and `saints/today` are absent from `lib/` (grep). | Covered |
| REQ-F09-002 | Injectable headers builder; no extra headers today | DS: injected header sent, builder failure gives Network, exact default header set (T), empty-map hook (T). PR: provider path sends only Accept+UA (T). | Covered |
| REQ-F09-003 | No valid base: no request, NotConfigured mentioning API_BASE_URL | DS: null base, 0 requests, message has `API_BASE_URL`. PR: null base, 0 requests. PR: invalid `API_BASE_URL` resolves to null, then NotConfigured, 0 requests (T). | Covered |
| REQ-F09-004 | OpenRouter code, tests, define and README removed | `grep -rli openrouter lib test README.md` finds no matches (exit 1). The deleted test files are gone. | Covered (static check) |
| REQ-F09-005 | Problem body parsed (status, code, requestId); malformed or missing falls back to status | PP: full body, no requestId, ill-typed members, 5 non-problem bodies. DS: 503 non-JSON, malformed problem bodies x4 (T), non-UTF-8 error body (T), plain `application/json` problem (T). | Covered |
| REQ-F09-006 | Mapping table | DS rows: <br>- 503 `saint_not_ready`: NotReady; <br>- 404 `saint_not_available`: DateUnavailable; <br>- 404 with no body: Unavailable; 404 `not_found`: Unavailable; <br>- 401 `app_check_required`: Unavailable; <br>- 400 `invalid_date`: Unavailable; <br>- 503 other code: Unavailable; 503 non-JSON: Unavailable; <br>- 500/502/204/302/429: Unavailable; <br>- transport and timeout: Network; <br>- null base: NotConfigured; <br>- (T) cross-checks: code on the wrong status (404 `saint_not_ready`, 503 `saint_not_available`) is Unavailable. <br>RI: the same mapping through the real stack. | Covered |
| REQ-F09-007 | Diagnostic message and log carry dateKey, status, code and requestId; never shown | DS: `messageContains` on 503/404/401/400/500/transport/timeout (T) including `requestId=` and `code=none`. RU: parse failures prefixed with dateKey. SC: `failure.message` never found on screen, for all six failure types plus the non-failure error (T). | Covered, with one gap: the `developer.log` line itself is not captured (see Gaps) |
| REQ-F09-008 | 200 JSON object to entity; named failures for malformed JSON, non-object, missing or wrong-typed field, bad dateKey; unknown fields ignored; mismatched key accepted | JP: valid payload, unknown fields, D-7 mismatch accepted, each of 10 fields missing and wrong-typed (20 cases), null field, 6 malformed dateKeys, whitespace dateKeys x3 (T), malformed JSON, array, null/string/number (T), empty body (T). DS: invalid-UTF-8 200 is Parsing. RI: missing field, malformed dateKey and non-UTF-8 200 are Parsing and not cached (T). | Covered |
| REQ-F09-009 | Empty or whitespace name, or all six sections empty: Parsing, not cached | RU: name `''` and `'   '`; all sections empty (incl. whitespace); one section is enough. RI: empty name leaves prefs unchanged (T). JP: the parser itself accepts all-empty, so the guard sits only in the repository (T). | Covered |
| REQ-F09-010 | Empty `saying` valid; Famous Saying card hidden | JP: valid payload with empty saying. SC: about-only saint hides the saying; full saint minus saying shows the 5 other labels and no Famous Saying (T). | Covered |
| REQ-F09-011 | Cache read under the same key before any request; hit means no network | RU: reads == requested == `2026-10-12`; hit gives no request. RI: real prefs entry, zero requests (T). PR: reload after success is a cache hit, 1 request (T). | Covered |
| REQ-F09-012 | Write under the server dateKey; best-effort; commit-last; corrupt entry is a miss | RU: server key written; failed write still returns. RI: stored under the server key; throwing platform write still returns (T); corrupt entry re-fetched and replaced (T). CA: commit-last order, failed value write doesn't commit the key, interrupted write is never stale, corrupt entry is a miss (kept). | Covered |
| REQ-F09-013 | Displayed dateKey and displayDate come from the server | RU: server `2026-10-13`/`October 13` returned for a `2026-10-12` request. SC: header shows the server displayDate (T). | Covered |
| REQ-F09-014 | Any failure leaves the cache unchanged | RU: 5 datasource failures plus an unexpected exception, no writes. RU: guard failures, no writes. RI: 8 failure kinds, prefs snapshot identical before and after (T). | Covered |
| REQ-F09-015 | Loading, header, sections and Try again unchanged | SC: loading spinner, success with all sections, no Icon widgets, Try again re-runs the load (T). TS: success sweep across 3 sizes x 3 scales. | Covered |
| REQ-F09-016 | Six exact messages; Try again at least 48px; reflow at 1.5x and 2.0x | SC: exact text for each of the 6 failures, Try again present, InkWell height >= 48. TS: 6 failures x {1.0, 1.5, 2.0} on 360x690 with no overflow exception. SC: a non-failure error shows the generic text (T). | Covered |
| REQ-F09-017 | Provider built from `httpClientProvider` + `apiBaseUriProvider`; `.g.dart` committed | PR wiring tests. `dart run build_runner build --delete-conflicting-outputs` left `lib/` with no diff. | Covered |
| REQ-F09-018 | ADR-0008, ADR-0005 superseded, README, RISK-008 resolved, RISK-F09-002/003 added | Static check: ADR-0008 exists; ADR-0005 status is superseded; README has "Saint of the Day (Parish API)"; RISK-008 is under Resolved; RISK-017/018 present. | Covered (docs) |
| REQ-F09-019 | `sydneyNow`/`sydneyDateKey` kept; midnight in AEST/AEDT; both DST windows | SD: offsets, padding, midnight in AEST and AEDT, New Year, both 2026 DST windows, 1st-is-Sunday DST windows 2028/2029 (T), leap day (T). RI: the AEDT rollover through the real clock composition (T). | Covered |
| REQ-F09-020 | Unit-test list | Each listed bullet maps to DS/JP/RU rows above. Cache tests kept. | Covered |
| REQ-F09-021 | Widget tests: loading, success incl. empty saying, six failures with Try again, text-scale sweep | SC + TS as above. | Covered |
| REQ-F09-022 | Live test; asserts name, dateKey and a section; skips on 503 `saint_not_ready` | LV: passed against production on 2026-10-12. Now tagged `live` (T). | Covered |
| REQ-F09-023 | format, analyze and test clean; `.g.dart` matches; other widget tests don't hit the network for Saint | Commands below. Only `SaintOfTheDayScreen` watches `saintOfTheDayProvider` in `lib/` (grep); `app_bar_chrome_test.dart` overrides it when it opens the screen. | Covered |

No REQ is uncovered.

## Commands and results
| Command | Result |
|---|---|
| `git status --short` / `git log -1` (start) | clean; `c9e1373` on `feature/09-saint-of-the-day-api` |
| `flutter test test/features/saint_of_the_day` (first pass, before the widget additions) | 194 passed |
| `flutter test` (after all additions, first run) | 1 failure, in my own new retry test (see below) |
| `dart format .` (final) | 201 files, 0 changed |
| `flutter analyze` (final) | No issues found |
| `flutter test` (final) | **611 passed, 2 skipped, 0 failed**. The 2 skips are the existing opt-in `release_readiness_test.dart` checks. |
| `flutter test --exclude-tags live` | **606 passed, 2 skipped, 0 failed** (5 live tests excluded) |
| `flutter test --tags live` | **5 passed** (bulletins 2, events 2, saint 1), all against production |
| `flutter test test/features/saint_of_the_day/data/datasources/saint_of_the_day_live_test.dart` | **1 passed**, 200 from production |
| `flutter test test/features/saint_of_the_day` (final) | 201 passed |
| `dart run build_runner build --delete-conflicting-outputs` | no diff in `lib/`; generated code matches its source |
| `grep -rli openrouter lib test README.md` | no matches |

### Failing case found during the phase
- My new "Try again re-runs the load" widget test failed at first, because the NotReady message never appeared.
- Cause: the shared `_pump` helper builds a `ProviderScope` without the app's `retry: noAutomaticRetry` policy. Riverpod's default automatic retry therefore called the override a second time, and it succeeded before the error view was shown.
- Fix: the test builds its own `ProviderScope(retry: noAutomaticRetry, ...)`, matching `main.dart`.
- This was a test-authoring issue, not a product defect: production uses `noAutomaticRetry`.

## Defects found
- None in lib code. No lib file was changed.

## Observations, not defects
1. **Header-builder failure maps to Network** (DS, coder test). Once App Check lands (RISK-018), a token-fetch failure would show "check your connection". That is acceptable today because the hook is unused, but App Check integration should revisit it.
2. **Server dateKey mismatch means a request on every load** that day (RI pins this). This is the accepted RISK-F09-006 behaviour. It is low impact, since the server echoes the requested key.
3. **Widget test harness hygiene.** The existing screen and text-scale tests pump without `noAutomaticRetry`. They pass because their overrides always fail. Any future test that varies its result between calls needs the app's retry policy, as above.
4. The datasource's `replace(pathSegments:)` would drop a base path. That can't happen, because `resolveApiBaseUri` returns an origin only, and it is the same as ministries.

## Unresolved coverage gaps
- **REQ-F09-007 log line.** The repository's `developer.log` output is not captured in tests, because `dart:developer` log isn't interceptable without a logging seam. The log content is the failure's `toString()`, whose `message` is asserted at the datasource level. Low risk.
- **Golden tests.** None for this screen. The data view is visually unchanged by this feature, and feature 06 shipped without goldens. I left this as is rather than adding baseline images in this phase.
- **Text-scale sweep for failure states.** It runs on the smallest phone (360x690) only, which is the worst case. Success states are swept across 3 sizes.
- **Live test offline.** It is still a hard failure in a plain offline `flutter test`. The workaround is `--exclude-tags live` (RISK-007 partly mitigated).

## Open risks
- RISK-007: open, partly mitigated (`live` tag added; default exclusion is a user decision).
- RISK-017 (= RISK-F09-002, device clock): accepted.
- RISK-018 (= RISK-F09-003, App Check enforce mode): open.
- RISK-F09-001 (503 just after midnight): mitigated by the NotReady message; tested.
- RISK-F09-004 (DST rule): pinned by fixed-time tests, including the 1st-is-Sunday years.
- RISK-F09-007 (old OpenRouter key): still the user's decision.

## Handoff
- Awaiting user approval. Next phase: VISUALISER_AGENT (per CLAUDE.md order BA -> Coder -> Tester -> App-Visualiser -> Verifier -> Deployer). Not committed; the main session commits.
