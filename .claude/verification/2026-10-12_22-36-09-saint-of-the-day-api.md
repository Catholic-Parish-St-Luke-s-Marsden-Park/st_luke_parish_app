# Verification Report — 09-saint-of-the-day-api

- Branch: `feature/09-saint-of-the-day-api`, HEAD `adda2f4`, 0 behind `origin/main` (`6ef2edd`), clean tree at start (confirmed 2026-10-12_23-52)
- Commits verified: `1b925d6` (start), `a73b3ea` (ba), `c9e1373` (coder), `f5a4a6b` (tester), `adda2f4` (visualiser)
- BA plan (user-approved): `.claude/plans/ba/2026-10-12_22-36-09-saint-of-the-day-api.md` (REQ-F09-001..023, D-1..D-8, RISK-F09-001..008)
- Approved post-BA change (not a deviation): 404 mapping tightened at coder handoff, so only 404 `saint_not_available` maps to DateUnavailable and any other 404 maps to Unavailable. The BA table, ADR-0008 and the code all agree on this.
- Read-only over `lib/` and `test/`. Nothing in either was modified.

## Command re-run (verifier, independent)
| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 201 files, 0 changed, exit 0 |
| `flutter analyze` | No issues found, exit 0 |
| `flutter test` | **611 passed, 2 skipped, 0 failed** (exit 0). The skips are the opt-in `RELEASE_CHECK` tests. The live saint test passed against production. |
| `flutter test --exclude-tags live` | **606 passed, 2 skipped, 0 failed** (exit 0). 611 - 606 = 5 live tests (bulletins 2, events 2, saint 1). |
| `dart run build_runner build --delete-conflicting-outputs` | Incremental run: all 193 inputs skipped, 0 outputs, so it was cached and proved nothing. Re-ran after `dart run build_runner clean`: wrote 16 outputs in 32s. `git status --porcelain` was empty afterwards, so the committed `.g.dart` files match their sources byte for byte. There was nothing to restore. |
| `git show --stat c9e1373` | `saint_of_the_day_provider.dart` and `saint_of_the_day_provider.g.dart` are in the same commit |

## Traceability Matrix — REQ-F09-001..023

Abbreviations. Code paths are relative to `lib/features/saint_of_the_day/`: `ds` = `data/datasources/saint_of_the_day_remote_datasource.dart`, `pp` = `data/parsers/problem_details_parser.dart`, `jp` = `data/parsers/saint_json_parser.dart`, `repo` = `data/repositories/saint_of_the_day_repository_impl.dart`, `fail` = `domain/failures/saint_of_the_day_failure.dart`, `prov` = `presentation/providers/saint_of_the_day_provider.dart`, `scr` = `presentation/screens/saint_of_the_day_screen.dart`, `ev` = `presentation/widgets/saint_of_the_day_error_view.dart`.

Test paths are relative to `test/features/saint_of_the_day/`: `dsT` = `data/datasources/saint_of_the_day_remote_datasource_test.dart`, `liveT` = `data/datasources/saint_of_the_day_live_test.dart`, `jpT` = `data/parsers/saint_json_parser_test.dart`, `ppT` = `data/parsers/problem_details_parser_test.dart`, `repoT` = `data/repositories/saint_of_the_day_repository_impl_test.dart`, `intT` = `data/repositories/saint_of_the_day_repository_integration_test.dart`, `sdT` = `data/sydney_date_test.dart`, `provT` = `presentation/providers/saint_of_the_day_provider_test.dart`, `scrT` = `presentation/screens/saint_of_the_day_screen_test.dart`, `tsT` = `presentation/screens/saint_of_the_day_screen_text_scale_test.dart`.

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| 001 `GET {base}/v1/saints/{dateKey}`: key computed once, 10s timeout, Accept + UA, UTF-8 from bytes, no `/today` or `/admin` | `repo:34` (key computed once), `repo:36`, `repo:58`; `ds:60` (path), `ds:32`, `ds:64-69`, `ds:83`; `prov:25` (`apiBaseUriProvider`). `grep "saints/today\|/admin" lib` returns nothing. | `dsT:43` (URL and headers), `:59` (never `/today`), `:83` (UTF-8 without charset), `:246` (10s timeout); `provT:132` (request goes through the shared client and `apiBaseUriProvider`); `intT:100` | ✅ |
| 002 Injectable headers hook that sends nothing today | `ds:11`, `ds:67`; `prov:23-26` passes no hook | `dsT:70` (injected header sent), `:269` (exactly Accept and UA by default), `:283`; `provT:154` (no App Check header through the real wiring) | ✅ |
| 003 No base means no request and NotConfigured; message names `API_BASE_URL` | `ds:53-59`; `fail:20` | `dsT:102`; `provT:194` (invalid `API_BASE_URL`), `:218` (zero requests) | ✅ |
| 004 OpenRouter code, define, prompt date and tests removed; no reference in lib, test or README | Files deleted in `c9e1373`. `grep -ri openrouter lib test README.md` returns nothing. `git grep -il openrouter -- . ':!.claude'` returns nothing (covers CI, fastlane and platform dirs). `sydneyFullDateForPrompt` and `sydneyDisplayDate` have no matches. | Old test files are absent from `test/.../datasources` and `/parsers` | ✅ |
| 005 Problem body parsed (status, code, requestId); a bad body falls back to status | `pp:8-31` (never throws); `ds:98-101` (`allowMalformed`) | `ppT:8`, `:20`, `:29`, `:47`; `dsT:200` (non-JSON 503), `:364` (malformed problem), `:373` (non-UTF-8 error body) | ✅ |
| 006 Mapping table, including the tightened 404 rule | `ds:109-115` (503+`saint_not_ready` is NotReady; 404+`saint_not_available` is DateUnavailable; everything else non-200 is Unavailable); `ds:70-73` (transport is Network) | `dsT:121` (503 not ready), `:132` (404 available), `:143` (404 without body is Unavailable), `:152` (404 other code is Unavailable), `:163` (401), `:178` (400), `:189` (503 other code), `:209` (500/502/204/302/429), `:228` (transport), `:246` (timeout), `:323`/`:335` (code on the wrong status) | ✅ |
| 007 Diagnostics carry dateKey, status, code and requestId, are logged, never shown | `ds:104-107`, `ds:56`, `ds:72`; `repo:47-50` (one `developer.log` per failure), `repo:73`, `repo:84`; `scr:39-61` maps type to fixed text and never uses `message` | `dsT:121` (`503`, `saint_not_ready`, `r-1`, dateKey), `:217` (`requestId=none`), `:384`, `:400`; `repoT:203`; `scrT:272` loop (`find.textContaining(failure.message)` finds nothing for all six) | ✅ |
| 008 200 JSON to entity; parsing failure names the field; `dateKey` must be valid; unknown fields ignored; mismatch accepted | `jp:18-61`, `jp:65-72` (real calendar date) | `jpT:32`, `:47` (unknown), `:55` (mismatch accepted), `:62`/`:69` (each field missing or wrong type), `:77`, `:92` (bad dateKey), `:100`, `:107`, `:120`, `:128`, `:133`, `:184` (impossible date) | ✅ |
| 009 Empty name or six empty sections is a parsing failure and is not cached | `repo:82-91`, `repo:112-119` (whitespace counts as empty, slightly stricter than the BA text; see note A) | `repoT:146` (name variants), `:160`, `:183` (one section is enough) | ✅ |
| 010 Empty `saying` is valid and the card is hidden | `scr:86`; `jp` accepts `""` | `jpT:32`; `scrT:160` (five cards and no Famous Saying) | ✅ |
| 011 Cache read under the same key first; a hit makes no request | `repo:34-37` | `repoT:79`, `:89`; `intT:118` (zero requests); `provT:174` | ✅ |
| 012 Write under the server `dateKey`, best-effort, commit-last, corrupt entry is a miss | `repo:41`, `repo:99-108`; `data/cache/saint_of_the_day_cache.dart:63-68` (corrupt is a miss), `:82-101` (commit-last), logic unchanged per D-2 | `repoT:101`, `:114`, `:132`; `intT:134` (corrupt), `:247` (throwing prefs write), `:296` (server key); `data/cache/shared_preferences_saint_of_the_day_cache_test.dart:84-158`; `data/cache/saint_of_the_day_cache_write_order_test.dart:101`, `:110` | ✅ |
| 013 Displayed `dateKey` and `displayDate` come from the server | `repo` returns the parsed entity unchanged; `sydney_date.dart` has no display helper left | `repoT:114`; `scrT:151` | ✅ |
| 014 Any failure leaves the cache unchanged | `repo:43-52` (write only after success) | `repoT:221-253` (five failure types plus an unexpected exception); `intT:170-245` (eight failure kinds, prefs unchanged byte for byte) | ✅ |
| 015 Loading view, header, cards and Try again unchanged | Header, loading view, section card and pill are not in the feature diff. `ev:25` changed `Padding` to `SingleChildScrollView` (an approved robustness change; same padding) | `scrT:43` (loading), `:53`, `:69`, `:89`, `:189` (Try again reloads) | ✅ |
| 016 Six exact messages; Try again at least 48px; reflow at 1.5x and 2.0x | `scr:43-60` (strings match the BA text exactly); `ev:41-44` (48x48 minimum) | `scrT:239-293` (exact text, Try again present, height of 48 or more for all six); `tsT:184-210` (6 failures x 1.0/1.5/2.0 on 360x690) | ✅ |
| 017 Provider uses `httpClientProvider` + `apiBaseUriProvider`; `.g.dart` committed | `prov:19-29`; `.g.dart` in `c9e1373` | `provT:113-236`; clean build_runner leaves 0 diff | ✅ |
| 018 ADR-0008, ADR-0005 superseded, README, RISK-008 resolved, RISK-F09-002/003 added | `.claude/decisions/0008-...md` (accepted, tightened 404 recorded); `0005` Status is "superseded by ADR-0008"; `README.md:45-56`, `:69-70`; `active-risks.md` RISK-008 resolved, RISK-017 (= F09-002, accepted), RISK-018 (= F09-003, open) | Static check | ✅ (note B: the RISK-008 resolution wording was stale and has been corrected by the verifier) |
| 019 `sydney_date.dart` keeps only `sydneyNow`/`sydneyDateKey`; midnight and both DST windows pinned | `data/sydney_date.dart:36`, `:43` (the only public members) | `sdT:44-63` (AEST/AEDT midnight, New Year, leap day), `:66-115` (April/October windows, including 2028/2029 edge years) | ✅ |
| 020 Unit tests for datasource, parser, repository; cache tests kept | See rows 001-014 | All listed tests exist and pass | ✅ |
| 021 Widget tests: loading, success (full and empty saying), six failures; text-scale sweep | — | `scrT:43`, `:53`, `:160`, `:239-293`; `tsT:107-210` | ✅ |
| 022 Resilient live test; skips on 503 not ready | — | `liveT` (`@Tags(['live'])`, `markTestSkipped` on `SaintOfTheDayNotReadyFailure`, checks name, dateKey and at least one section). It passed in this run. | ✅ |
| 023 Format, analyze, test clean; `.g.dart` matches; shell tests don't hit the network | Saint providers are watched only by `scr:22` | Command table above; `test/app/shell/app_bar_chrome_test.dart:133` overrides `saintOfTheDayProvider`; no other test pushes the screen unmocked | ✅ |

**Result: 23 of 23 requirements are traced to code and tests. None is untraced, and no code mismatch was found.**

### Notes
- **A (not a defect):** The content guard trims whitespace (`repo:119`) while the screen tests `isNotEmpty` (`scr:79-101`). So a whitespace-only section in an otherwise valid payload would render as a blank card. The guard only stops an all-blank page. This is cosmetic, needs a server bug to happen, and doesn't break any REQ.
- **B (doc, fixed):** The RISK-008 resolution note said "404 => check your date and time settings". After the tightening, only 404 `saint_not_available` gives that message. I appended a correction note to the risk register. The original text is kept.
- **C (observation):** `repo:36` (cache read) and `prov:21` (`SharedPreferences.getInstance()`) are outside the typed-failure wrapper. An exception there would reach the screen as a raw error. The screen still shows the generic message (`scr:42`, tested at `scrT:220`), so no raw text leaks. It just isn't logged by the repository. Low.
- **D (doc, out of verifier scope):** CLAUDE.md "Project Overview" still says the parish API is used for "currently ministries via `GET /v1/ministries`". It is now also used for `/v1/saints/{date}`. This doesn't break the rules (they allow `GET /v1/*`), but the user may want to update the wording. The verifier may not edit CLAUDE.md.

## CLAUDE.md compliance
| Rule | Finding |
|---|---|
| Layering: no network or parsing in widgets | `grep "package:http\|jsonDecode\|http.get" lib/features/*/presentation` returns nothing. The screen only watches the provider and maps failure types to strings. |
| Only public `GET /v1/*` (plus `POST /tokens`) | The only new call is `_client.get` on `/v1/saints/{dateKey}` (`ds:69`). There are no `/admin`, `/today` or authenticated calls. |
| No secrets in source | No key or token is in the feature. `assets/app.env` holds only the URLs. The OpenRouter define is gone repo-wide. |
| `grep -ri openrouter lib test README.md` | Empty |
| Typed failures, no raw exception text in UI | Sealed `SaintOfTheDayFailure` with six subtypes; the switch in `scr:43` is exhaustive. `scrT:272` asserts the diagnostics never render. |
| 48dp targets | Try again `InkWell` has a 48x48 minimum (`ev:41-44`), asserted for all six failures |
| No font below 12 | The only literal `fontSize` in the feature is `saint_of_the_day_header.dart:36` = 12. That file is unchanged and at the limit, not below it. The error view uses `textTheme.bodyMedium`. |
| Text-scale reflow | 6 failures x 3 scales on the smallest phone, plus the existing success, loading and minimal sweeps, all pass |
| `.g.dart` committed with source | Yes, same commit, and a clean rebuild leaves 0 diff |
| Logging without secrets | `developer.log` writes only the path, status, dateKey, code and requestId |

## Docs and risk bookkeeping
- ADR-0005: Status is "superseded by ADR-0008". ✅
- ADR-0008: matches the code, including the tightened 404 rule, D-1..D-8, the clock trade-off and the App Check hook. ✅
- RISK-008: resolved. The resolution note's 404 wording has been corrected (note B). ✅
- RISK-007: "open, partly mitigated". `dart_test.yaml` has a `live` tag and the 3 live files are tagged. A plain `flutter test` still runs them; whether to exclude them by default is the user's decision before CI. Accurate. ✅
- RISK-017 (device clock): accepted. RISK-018 (App Check enforce): open. Both are accurate. ✅
- RISK-F09-007 (revoke or rotate the old OpenRouter key): it was in the BA plan, ADR-0008 and memory, but **not in the risk register**. Logged by the verifier as **RISK-019**, a user decision. ⚠️ (fixed in the register)
- Visualiser coverage gap: logged as **RISK-020** (see below).

## Visualiser adequacy (my judgement)
The visualiser evidence is **adequate for this feature, but it is thin**:
- The live render confirmed the parts only a device can show: the real data path (no OpenRouter key in the build), the server `displayDate`, the hidden empty saying, and no crash on a cold cache.
- What wasn't exercised live (failure messages, cache reopen, large font) is either pure logic or fixed text in an existing widget. Those are well covered by automated tests: the datasource maps every row, `intT` uses real prefs, `scrT` checks exact strings, and `tsT` sweeps 1.0/1.5/2.0x on 360x690.
- The only new layout is the scrollable error view, and it is tested at 2.0x on the smallest phone.
- However, no person checked the screen by hand, and below-the-fold cards and large-font rendering were never seen on a real device. That is the same class of gap as RISK-006. It is low impact here because the data view is visually unchanged from feature 06, which had a human review.
- Logged as RISK-020 (low, recommended: a 2-minute device check during Deployer). It doesn't block the verdict.

## Verdict
**PASS.** All 23 requirements are traced to code and tests, with no mismatches. The quality gates were re-run independently. No implementation or test changes are needed.

Open risks for Deployer: RISK-019 (user decision: revoke or rotate the old OpenRouter key), RISK-018 (App Check enforce coordination), RISK-020 (optional device check of failure states and large font), RISK-007 (whether live tests run by default before CI), and RISK-017 (accepted).
