# BA_AGENT Plan

- Feature ID: 09
- Feature Slug: saint-of-the-day-api
- Branch: feature/09-saint-of-the-day-api
- Phase: ba
- Timestamp: 2026-10-12_22-36
- Status: **user-approved 2026-10-12**. All open questions answered (see User-confirmed decisions).

## Inputs
- User request (verbatim): "I want to change the saint of the day implementation to point to the saint of the day end point listed here and retrieve the saint of the day https://parish-app-service.fly.dev/docs"
- The user's answers to OQ-1..OQ-7 (verbatim): "1/ remove it completely 2/ keep it 3/ date 4/ recomended 5/ agree 6/ agree 7/ agree"
- Root `CLAUDE.md`. It permits the parish API's public, read-only `GET /v1/*` endpoints and forbids `/admin` and anything authenticated.
- `.claude/memory.md` (feature 09, phase ba).
- Feature 06 BA plan `.claude/plans/ba/2026-09-01_01-34-06-saint-of-the-day.md` and ADR-0005 `.claude/decisions/0005-saint-of-the-day-direct-openrouter-call.md`.
- Feature 08 BA plan `.claude/plans/ba/2026-10-08_10-51-08-ministries-api.md` and ADR `.claude/decisions/0006-ministries-from-parish-api.md`. This is the pattern to mirror.
- RISK-008 in `.claude/risks/active-risks.md`.
- The parish API contract, read on 2026-10-12 from `https://parish-app-service.fly.dev/openapi.yaml`, plus one live call:
  - `GET /v1/saints/{date}` (`YYYY-MM-DD`, Sydney): only yesterday, today or tomorrow. Responses:
    - 200 `Saint`;
    - 404 `saint_not_available` for any other date;
    - 400 `invalid_date`;
    - 503 `saint_not_ready` (the background job hasn't prepared that day's saint yet);
    - 401 `app_check_required`, only in App Check enforce mode.
  - `GET /v1/saints/today` exists too. This feature doesn't use it.
  - `Saint` schema ("mirrors the Flutter `SaintOfTheDay` entity"). Required fields: `name, feast, bornDied, about, saying, didYouKnow, patronOf, prayer, dateKey (date), displayDate`. `saying` is empty when no reliably attributed saying is known.
  - Errors are RFC 9457 `application/problem+json`: `type, title, status, code`, plus optional `detail` and `requestId`.
  - App Check: a `X-Firebase-AppCheck` token is required only when the server runs `APP_CHECK_MODE=enforce`. The default `monitor` mode never requires it.
  - The live `GET /v1/saints/today` returned 200: "Saint Wilfrid, Bishop", `dateKey` "2026-10-12", `displayDate` "October 12", `saying` "".

## User-confirmed decisions (2026-10-12)
- **D-1 (OQ-1): Remove OpenRouter completely.** Delete:
  - `openrouter_saint_datasource.dart` and `saint_text_parser.dart`;
  - the `OPENROUTER_API_KEY` dart-define and `sydneyFullDateForPrompt`;
  - their tests;
  - the README "Saint of the Day (OpenRouter API key)" section.

  A new ADR-0008 supersedes ADR-0005. No fallback is kept.
- **D-2 (OQ-2): Keep the on-device per-day cache.** It is still shared_preferences, holds one entry, writes the value before the key, and treats a corrupt entry as a miss.
- **D-3 (OQ-3): Use `GET /v1/saints/{date}`, not `/today`.** The date is the client-computed Sydney date key, `sydneyDateKey(sydneyNow())` from `sydney_date.dart`.
  - The same key is used for the cache lookup and the request path.
  - `/today` is out of scope.
- **D-4 (OQ-4): 503 `saint_not_ready` gets its own message.** It reads "Today's saint is still being prepared. Please try again in a few minutes."
- **D-5 (OQ-5): 401 `app_check_required` shows the generic "temporarily unavailable" message.** The status, `code` and `requestId` are logged.
- **D-6 (OQ-6): Some 200 responses count as parsing failures.** That applies when `name` is empty, or when all six content sections are empty. The user is offered a retry and nothing is cached.
- **D-7 (OQ-7): The server's `dateKey` is checked for format only, never rejected for not matching.** The server's `dateKey` and `displayDate` are what get stored and displayed. With `/{date}`, the server's `dateKey` should normally equal the requested key.
- **D-8 (BA choice under D-3, stated for review): how 404 and 400 map.**
  - 404 `saint_not_available` can only happen if the device clock is more than about a day off, so it gets its own failure. The message asks the user to check their phone's date and time, because that's something they can fix.
  - 400 `invalid_date` can only be an app bug, since the client always sends a well-formed key. It gets the generic "temporarily unavailable" message and is logged.

## Current State (what this feature replaces)
- `lib/features/saint_of_the_day/data/datasources/openrouter_saint_datasource.dart` POSTs to OpenRouter with a build-time `--dart-define=OPENROUTER_API_KEY`. The key ships inside the app binary, which ADR-0005 accepted as a trade-off.
- `data/parsers/saint_text_parser.dart` uses regex to parse the model's `**LABEL:**` free text.
- `data/repositories/saint_of_the_day_repository_impl.dart` runs: client-computed Sydney date key -> cache read -> fetch -> parse -> "has renderable content" guard -> best-effort cache write.
- `data/cache/saint_of_the_day_cache.dart` (shared_preferences) keeps one entry, for one Sydney day, and writes the value before the key.
- `data/sydney_date.dart` hand-codes the NSW daylight-saving rule. It produces the date key, the display date and the prompt date.
- Failures: sealed `SaintOfTheDayFailure` with `NotConfigured` (missing key), `Network` and `Parsing`. RISK-008: every non-200 response shows the same "check your connection" message.
- Observation: a repo-wide grep found `OPENROUTER_API_KEY` only in `README.md`, the datasource, the failure file and one repository test. Nothing in `.github/` or fastlane passes it. CI-built store binaries therefore probably have no key, and probably show "Saint of the Day isn't set up on this build yet." This was not verified on a store build. If it's true, this feature fixes a live production gap as well as the shipped-key risk.

## Feature Summary
The Saint of the Day screen gets its data from the parish API's `GET /v1/saints/{date}`, using the device's Sydney date, instead of calling OpenRouter from the device. The server has already generated and stored that day's saint as structured JSON, so the app no longer needs an AI key, a prompt or free-text parsing. The screen, the AppBar pill and the section layout look the same. Error messages become specific: "not ready yet", "check your phone's date", "temporarily unavailable" and "no connection" are told apart, which resolves RISK-008.

## In Scope
- A remote datasource for `GET /v1/saints/{dateKey}`, mirroring `MinistriesRemoteDatasource`:
  - it takes the date key as a parameter;
  - 10s timeout;
  - `Accept: application/json` and the app User-Agent;
  - UTF-8 decoded from the raw bytes;
  - an injectable request-headers hook (for App Check later), sending nothing today.
- A parser for RFC 9457 problem responses, used to map `status` + `code` to typed failures and to log `requestId`.
- A JSON parser and validator from the `Saint` payload to the existing `SaintOfTheDay` entity.
- An updated sealed failure hierarchy, and screen messages for each failure.
- Repository rewrite. It computes the Sydney date key once, reads the cache under it, then fetches `/{dateKey}`. After that it validates the response and attempts a best-effort cache write under the server's `dateKey`.
- `sydney_date.dart` is reduced to `sydneyNow` and `sydneyDateKey`. `sydneyFullDateForPrompt` is removed. `sydneyDisplayDate` is removed unless the Coder finds another caller.
- Rewiring `saintOfTheDayRepositoryProvider` to use `httpClientProvider` and `apiBaseUriProvider`, and regenerating `.g.dart`.
- Removing the OpenRouter code, tests and README section (D-1).
- ADR-0008 (superseding ADR-0005), a README update, and RISK-008 closed in `active-risks.md`.
- Tests: unit, widget and a live integration test (REQ-F09-020..022).

## Out of Scope
- `GET /v1/saints/today` (D-3).
- Browsing yesterday's or tomorrow's saint. Only the client's Sydney "today" is requested.
- Any visual change to `SaintOfTheDayScreen`, its widgets or `saint_of_the_day_pill.dart`, apart from new error-message text.
- Firebase App Check integration (`firebase_app_check` package, attestation setup). Only the header hook is added.
- Server-side changes to parish_app_service.
- ETag / `If-None-Match`, and honouring `Cache-Control` max-age on the device.
- Automatic retry, polling, or falling back to another date on 503 or 404. The user taps "Try again".
- A bundled fallback saint.
- Replacing `sydney_date.dart` with the `timezone` package. It is already a dependency through 08-events-calendar, but switching isn't needed here; see RISK-F09-004.
- Other features.

## Assumptions
- A-1: `/v1/saints/{date}` stays public, unauthenticated and read-only. That makes it allowed under `CLAUDE.md` with no rule change.
- A-2: `API_BASE_URL` in `assets/app.env` is already `https://parish-app-service.fly.dev` in every build, so no new configuration is needed.
- A-3: The server returns all 10 required fields as strings, and `dateKey` is `YYYY-MM-DD`. Unknown extra fields may appear later and are ignored.
- A-4: Any field except `name` may be an empty string. `saying` is empty by design.
- A-5: The server stays in App Check `monitor` mode until the app ships an App Check token.
- A-6: The server accepts yesterday, today and tomorrow in Sydney time. A client clock that is out by less than about a day still gets a valid date.

## Risks
- RISK-F09-001: The day's saint may not be ready right after Sydney midnight.
  - Until the background job finishes, `/{today}` can return 503 `saint_not_ready`.
  - If the device clock runs slightly ahead, it asks for tomorrow's date, which may not be prepared yet.
  - Mitigation: the distinct "still being prepared" message and Try again (D-4).
- RISK-F09-002 (device clock decides the day): D-3 means the device clock now chooses which saint is requested.
  - The date is computed from UTC (`DateTime.now().toUtc()`), so the device's timezone setting doesn't matter. Only absolute clock error does.
  - A clock off by less than a day may show yesterday's or tomorrow's saint with the server's matching `displayDate`. That content is coherent, just for a neighbouring day.
  - A clock off by more than a day gets 404 `saint_not_available`, which shows the "check your phone's date and time" message (D-8).
  - Accepted by the user when choosing `/{date}` over `/today`.
- RISK-F09-003: If the server switches `APP_CHECK_MODE=enforce`, every request gets 401 and the feature breaks for all users until an App Check build ships. Mitigation: a header hook now, logged code and `requestId`, and coordination with the server owner. Feature 08 carries the same risk.
- RISK-F09-004 (DST rule in `sydney_date.dart`): the hand-coded NSW rule switches offset at 00:00 UTC on the first Sunday of April or October. The real switch is at 16:00 UTC on the Saturday before.
  - So for about 8 hours, the computed Sydney time is off by an hour.
  - Analysis: that window falls on Sunday between roughly 02:00 and 11:00 Sydney time, so the calendar date (and so the requested date) is not affected.
  - Residual risk: if NSW changes its DST rule in law, the rule must be updated, or the date will be wrong for an hour near midnight. Low impact. The Tester should pin both changeover windows with fixed-time unit tests.
- RISK-F09-005: Single point of dependency. If parish-app-service is down, nothing is shown except a cached same-day entry. Accepted.
- RISK-F09-006: The server's `dateKey` might differ from the requested key, though with `/{date}` it shouldn't. The entry would then be stored under the server key and the next same-day lookup would miss, costing one extra request. No wrong content is shown. Low impact (D-7).
- RISK-F09-007: Removing the OpenRouter path can only be undone by reverting the feature (D-1). Whether to revoke or rotate the existing OpenRouter key, which older installs may contain, is for the user to decide outside this feature.
- RISK-F09-008 (carried over): the live integration test needs network access. RISK-007 applies.

## Unknowns / Open Questions
- None blocking. OQ-1..OQ-7 are resolved as D-1..D-7. D-8 is a BA mapping choice the user can still change at Coder handoff.

## Acceptance Criteria

### Data source
- `REQ-F09-001`: The app fetches `GET {apiBase}/v1/saints/{dateKey}`.
  - `dateKey` is `sydneyDateKey(sydneyNow())`, computed once per load by the repository and passed to the datasource.
  - The origin comes from `apiBaseUriProvider`.
  - 10s timeout; headers `Accept: application/json` and the app User-Agent.
  - The body is decoded as UTF-8 from the raw bytes.
  - `/v1/saints/today`, `/admin` and authenticated endpoints are never called.
- `REQ-F09-002`: The datasource accepts an injectable request-headers builder, for a future `X-Firebase-AppCheck` header. No extra headers are sent today.
- `REQ-F09-003`: With no valid API base, no request is made and the failure is `SaintOfTheDayNotConfiguredFailure` (the message now refers to `API_BASE_URL`, not an API key).
- `REQ-F09-004`: The following are removed:
  - the OpenRouter datasource;
  - `saint_text_parser.dart`;
  - the `OPENROUTER_API_KEY` dart-define;
  - `sydneyFullDateForPrompt`;
  - `openrouter_saint_datasource_test.dart` and `saint_text_parser_test.dart`.

  No reference to OpenRouter remains in `lib/`, `test/` or `README.md`.

### Error mapping (resolves RISK-008)
- `REQ-F09-005`: When a non-200 response has an `application/problem+json` body, its `status`, `code` and optional `requestId` are parsed. A missing or malformed problem body doesn't crash; it falls back to mapping by HTTP status alone.
- `REQ-F09-006`: Failure mapping (class names are indicative, one class per user-visible message):

  | Response | Failure |
  |---|---|
  | 503 `saint_not_ready` | `SaintOfTheDayNotReadyFailure` |
  | 404 (incl. `saint_not_available`) | `SaintOfTheDayDateUnavailableFailure` |
  | 401 (incl. `app_check_required`) | `SaintOfTheDayUnavailableFailure` |
  | 400 (incl. `invalid_date`) | `SaintOfTheDayUnavailableFailure` |
  | other 503, other 5xx, other non-200 | `SaintOfTheDayUnavailableFailure` |
  | timeout / transport error | `SaintOfTheDayNetworkFailure` |
  | no API base | `SaintOfTheDayNotConfiguredFailure` |
- `REQ-F09-007`: Each failure's diagnostic `message`, and the log line written for it, include the requested `dateKey`, the HTTP status, the problem `code` and the `requestId` when present. None of these ever appear in text shown to the user.

### Parsing and validation
- `REQ-F09-008`: A 200 body is decoded as a JSON object into `SaintOfTheDay`. The result is a `SaintOfTheDayParsingFailure` that names the field when:
  - the JSON is malformed or not an object;
  - any of the 10 required fields is missing, or not a string;
  - `dateKey` is not a well-formed `YYYY-MM-DD`.

  Unknown fields are ignored. A `dateKey` that differs from the requested key is accepted, not rejected (D-7).
- `REQ-F09-009`: These 200 responses are a `SaintOfTheDayParsingFailure` and are not cached (D-6):
  - an empty or whitespace-only `name`;
  - all of `about, bornDied, saying, didYouKnow, patronOf, prayer` empty.
- `REQ-F09-010`: An empty `saying` is valid. The "Famous Saying" card is simply hidden, as today.

### Cache
- `REQ-F09-011`: Before any request, the repository reads the cache under the same `dateKey` it will request. A hit returns the cached saint and makes no network call.
- `REQ-F09-012`: After a valid 200, the saint is written to the cache under the server's `dateKey`. The cache keeps:
  - best-effort writes: a failed write is logged, not rethrown;
  - commit-last ordering;
  - corrupt-entry-as-miss behaviour.
- `REQ-F09-013`: The displayed `dateKey` and `displayDate` come from the server response, not from `sydney_date.dart`.
- `REQ-F09-014`: Any failure leaves the cache unchanged.

### Presentation
- `REQ-F09-015`: `SaintOfTheDayScreen` keeps its existing loading view, header, section cards and Try again behaviour. The data view looks the same.
- `REQ-F09-016`: The error view shows these messages:
  - Not ready: "Today's saint is still being prepared. Please try again in a few minutes."
  - Date unavailable: "Today's saint isn't available for your phone's current date. Please check your date and time settings, then try again."
  - Unavailable: "Saint of the Day is temporarily unavailable. Please try again later."
  - Network: "Unable to fetch today's saint. Please check your connection and try again."
  - Not configured: "Saint of the Day isn't set up on this build yet. Please let the parish app team know."
  - Parsing: "Something went wrong loading today's saint. Please try again."

  Every state keeps the Try again button (at least 48px tall) and reflows at 1.5x and 2.0x text scale.
- `REQ-F09-017`: `saintOfTheDayRepositoryProvider` is built from `httpClientProvider` and `apiBaseUriProvider`, and the regenerated `.g.dart` is committed with its source.

### Documentation and risk register
- `REQ-F09-018`: Documentation and the risk register are updated.
  - ADR-0008 records the move from a direct OpenRouter call to `GET /v1/saints/{date}`, including the `/{date}` vs `/today` choice and its device-clock trade-off.
  - ADR-0005 is marked superseded.
  - The README Saint of the Day section is rewritten: no API key is needed and the source is `API_BASE_URL`.
  - RISK-008 is marked resolved in `.claude/risks/active-risks.md`. RISK-F09-002 and RISK-F09-003 are added there.
- `REQ-F09-019`: `sydney_date.dart` keeps `sydneyNow` and `sydneyDateKey`. Fixed-time unit tests pin:
  - the date around Sydney midnight in AEST and AEDT;
  - both DST changeover windows, showing the calendar date is unaffected (RISK-F09-004).

### Tests and quality gates
- `REQ-F09-020`: Unit tests cover:
  - Datasource:
    - the request URL includes the given `dateKey`, and the headers are correct;
    - one test per row of the REQ-F09-006 table;
    - a problem body with and without `requestId`;
    - a non-JSON error body.
  - JSON parser:
    - a valid payload, including an empty `saying`;
    - each required field missing or the wrong type;
    - a bad `dateKey`;
    - a `dateKey` that differs from the requested key, which is accepted;
    - an unknown field;
    - malformed JSON.
  - Repository, with an injected clock:
    - the cache is read and the request made with the same key;
    - a cache hit means no fetch;
    - a miss fetches and writes under the server `dateKey`;
    - a failed write still returns the saint;
    - the empty-name and empty-content guards;
    - failures leave the cache untouched;
    - rollover past Sydney midnight requests the new date.
  - The existing cache and write-order tests are kept.
- `REQ-F09-021`: Widget tests, driven by a fake repository, cover:
  - loading;
  - success, with all sections and with an empty saying;
  - each of the six failure messages, with Try again.

  The text-scale sweep at 1.0x, 1.5x and 2.0x covers the new error states.
- `REQ-F09-022`: A resilient live integration test computes today's Sydney key with `sydneyDateKey(sydneyNow())` and calls `GET https://parish-app-service.fly.dev/v1/saints/{key}`.
  - On 200, it asserts a non-empty `name`, a well-formed `dateKey` and at least one content section.
  - On a 503 `saint_not_ready` problem response, it is skipped, not failed.
- `REQ-F09-023`: `dart format`, `flutter analyze` and `flutter test` are clean, and the generated `.g.dart` matches its source. Shell and other widget tests don't touch the network for Saint of the Day.

## Handoff
- Approved by the user on 2026-10-12.
- Next phase: CODER_AGENT.
