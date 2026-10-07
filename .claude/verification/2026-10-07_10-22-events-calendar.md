# Verification Report — 08-events-calendar

- Branch: `feature/08-events-calendar`
- Coder commit: `2643e9c`
- Tester commit: `5ceac53`
- Visualiser commits: round 1 (`7422dc6`) / round 2 (`666e390`) / round 2.5+round 3 (`975ba19`) / phase-close (`b628378`)
- Verifier session: 2026-10-07_10-22

## Command Re-Run — Environment Constraint Carried Through Every Phase

Same constraint as the 06 and 07 verifier phases before it: this session has no Flutter SDK reachable (`git` works against the mounted project folder; `flutter`/`dart` do not). This phase cannot independently re-run validation — it relies on the user's own confirmed re-run from the visualiser phase's final (round 3) gate, re-stated here rather than re-run:

| Command | Result (user-confirmed, visualiser round 3, 2026-10-01) |
|---|---|
| `flutter analyze` | Clean |
| `dart format . --set-exit-if-changed` | Clean |
| `flutter test` | **354 passed, 1 skipped (pre-existing), 0 failed** |

No `lib/`/`test/` files have changed since that confirmed run (the visualiser phase-close commit `b628378` touched only `.claude/` bookkeeping — plan, journal, memory, feature-index), so this remains the current, accurate state. Flagged as a methodology deviation from the earliest verifier phases in this repo (which each independently re-ran the commands fresh) rather than silently presented as an independent check. Recommend one more fresh `flutter analyze`/`dart format`/`flutter test` pass immediately before Deployer/PR.

## Independent Code Read — `lib/features/events/` (all 17 files) + News-tab wiring

Read directly this session (not from the coder/tester/visualiser plans' descriptions): all 17 files under `lib/features/events/{domain,data,presentation}/`, the generated `events_provider.g.dart`, `lib/features/news/presentation/screens/news_screen.dart` (insertion point), and `lib/core/constants/external_links.dart`. Also read all 4 test files under `test/features/events/**`. Cross-checked exact file:line evidence against every REQ (table below) rather than trusting the upstream plans' claims. No discrepancies found between those plans' self-reports and the actual code, with one exception noted under RISK-013 below (a gap in live functional verification, not a code/test mismatch).

## Visualiser-Phase Retirements/Amendments — Carried Into This Matrix

The visualiser phase's three live-feedback rounds (explicitly user-authorized direct fixes, a documented deviation from the default no-rework-loop/file-as-issue procedure — see `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md`'s "Deviation From Default No-Rework-Loop Procedure" section) retired or amended five of the original 39 requirements:

- **REQ-F08-021** (the "View all upcoming events" link) — retired. Superseded by `_WeekPaginationBar`'s inline `< Back` / `More events >` controls within `EventsSection` itself.
- **REQ-F08-027..030** (the standalone `AllEventsScreen`'s reachability, full-list rendering, pagination, and shared-state reuse) — retired/moot. The screen (and its test file) were deleted; confirmed via `grep -rn "AllEventsScreen" lib/ test/` this session, which finds only historical doc-comment mentions explaining the retirement (and the known, accepted cosmetic `events_provider.g.dart` doc-comment drift pending the next `build_runner build`) — no functional reference remains.
- **REQ-F08-032** (no-Icon convention) — amended. The calendar glyph on "Add to my calendar" is now a deliberate, user-confirmed exception (the app's first-ever `Icon` widget); "no emoji glyph anywhere" is unaffected and still holds in full.

Each is marked **Retired** or **Amended** in the matrix below rather than silently omitted, per the verifier-agent's "reject incomplete traceability" rule — the point is to show these were deliberately, traceably closed out, not dropped.

## Traceability Matrix — REQ-F08-001..039

### Feed fetch & parsing

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-001 | `data/datasources/parish_events_feed_datasource.dart:12-39` — `ParishEventsFeedDatasource.fetchFeedIcs()`, 10s `_timeout`, custom `User-Agent`; `grep -rln "package:http" lib/features/events/` (this session) shows only this one file imports `http` | `test/.../parish_events_feed_live_test.dart:79-89` (raw body shape) | Pass |
| F08-002 | `data/parsers/ics_event_parser.dart:89-94,140-194` — `_extractField` regex extracts `SUMMARY`/`DESCRIPTION`/`LOCATION`/`DTSTART`/`DTEND`/`UID`/`URL`; `:73-77` `_unfoldIcs` handles RFC 5545 folded continuation lines before block-splitting | `ics_event_parser_test.dart` — "parses title, uid, start, location, description, url" (line 25) + "line folding" group (line 161) | Pass |
| F08-003 | `_parseIcsDateTime` (`ics_event_parser.dart:96-126`) handles full date-time (`Z`-suffixed and floating-local identically, by design — see class doc at `:17-25`) and date-only forms | `ics_event_parser_test.dart` — full-datetime case (line 25), all-day case (line 73) | Pass |
| F08-004 | Every per-block parse is inside a `try`/`catch` (`:148-249`) reporting via `onSkippedBlock` and `continue`-ing, never throwing out of `parseIcsEvents` | `ics_event_parser_test.dart` — missing-SUMMARY (line 93), missing-DTSTART (line 108), one-malformed-doesn't-block-a-later-valid-one (line 121) | Pass |
| F08-005 | `feed_events_repository.dart:56-57` — explicit ascending sort by `start`. Past-event exclusion: `ics_event_parser.dart:196-225` filters every branch (the RRULE branch's own `rule.getInstances(after: now, ...)` call at `:204-211`, the unparseable-RRULE fallback at `:217-220`, and the non-recurring branch at `:222-225`) on **`start` alone**, not "end, falling back to start" as the requirement specifies | `ics_event_parser_test.dart` — past-event-excluded (line 58); live test re-asserts ascending sort (`parish_events_feed_live_test.dart:68-76`) | **Partial — see RISK-012 (carried forward, open, unchanged)** |
| F08-006 | `ics_event_parser.dart:10,196-225` — `eventsLookaheadDays = 180`; `RecurrenceRule.fromString('RRULE:${rruleField.value}')` + `rule.getInstances(start:, after:, before:)` genuinely expands multiple occurrences, with a documented fallback to the template's own single occurrence if the `RRULE` itself is unparseable | `ics_event_parser_test.dart` — "a weekly RRULE expands into multiple future occurrences" (line 184, asserts 3 distinct Sunday occurrences a week apart) + dedup test (line 206) | Pass |
| F08-007 | `pubspec.yaml:59-61` — `rrule: ^0.2.18`, `timezone: ^0.11.1`, `add_2_calendar: ^3.1.1`, all direct dependencies | N/A (dependency-manifest check) | Pass |

### Domain / data architecture

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-008 | `domain/entities/parish_event.dart:9-67` — `ParishEvent`, a `const`-constructible immutable class, no `Map` anywhere in its API | Used as the typed return value throughout `events_provider_test.dart`/`events_section_test.dart` | Pass |
| F08-009 | `domain/repositories/events_repository.dart:10-16` — abstract `EventsRepository` (single method `getUpcomingEvents()`); `data/repositories/feed_events_repository.dart:29-109` — `FeedEventsRepository` is the sole concrete implementation, orchestrating fetch -> parse/expand -> URL-validate -> sort -> map; `grep -rln "FeedEventsRepository(" lib/` (this session) shows it's constructed only in `events_provider.dart:17-19` | `events_provider_test.dart` (provider-level, via a fake `EventsRepository`) + `parish_events_feed_live_test.dart` (real implementation, end to end) | Pass |
| F08-010 | `feed_events_repository.dart:38-41` — datasource's `EventsFailure` is rethrown unchanged; `parish_events_feed_datasource.dart:30-37` — every network exception/non-200 is converted to `EventsNetworkFailure` before it ever leaves the datasource | `events_provider_test.dart:115-139` (`EventsNetworkFailure` surfaces as `AsyncError`) | Pass |
| F08-011 | `feed_events_repository.dart:47-52,75-84` — an empty-body response and any unexpected parse/map exception both become `EventsParsingFailure`, distinct from `EventsFailure` subtypes rethrown unchanged (so an individually-skipped malformed `VEVENT` per REQ-F08-004 never raises this) | `events_provider_test.dart:142-165` (`EventsParsingFailure` surfaces as `AsyncError`) | Pass |
| F08-012 | `presentation/providers/events_provider.dart:32-34` — `@riverpod Future<List<ParishEvent>> upcomingEvents(Ref ref)`, generated as `AutoDispose...FutureProvider` (confirmed in `events_provider.g.dart:94-103`, `isAutoDispose: true` at `:119`); `EventsSection` is the sole reader (the former second reader, `AllEventsScreen`, was retired — see "Visualiser-Phase Retirements" above; the generated file's doc comment still names it, a known cosmetic-only drift pending the next `build_runner build`, same pattern as other features' `.g.dart` files in this repo) | `events_provider_test.dart` (loading/success/empty/network-failure/parsing-failure `AsyncValue` states, lines 36-166) | Pass |
| F08-013 | `events_section.dart:1-16` — imports only `../providers/events_provider.dart` (plus the shared pure time helper `sydneyNowAsFakeUtc`, display-windowing only, not fetch/parse/export); `grep -rln "data/datasources\|data/repositories\|data/parsers" lib/features/events/presentation/` (this session) returns no matches except the one explicitly-scoped `sydneyNowAsFakeUtc` import | Structural — confirmed by direct read | Pass |

### Inline "Upcoming Events" section UI states

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-014 | `events_section.dart:62` — `loading: () => const EventsLoadingView()`; `events_loading_view.dart:8-34` — explicit spinner + "Loading upcoming events…" text | `events_section_test.dart:132-148` (REQ-F08-014 group) | Pass |
| F08-015 | `events_section.dart:76-87` — `thisWeek` slice bounded to `[weekStart, weekEnd)` where `weekEnd = now + 7 days` on week 0; `event_row.dart:61-105` — date/time pill, bold title, italic location (only when non-null) | `events_section_test.dart:150-202` (REQ-F08-015 group — within-week render, no-location case, >7-days-out exclusion) | Pass |
| F08-016 | `events_section.dart:70-73` — fully-empty (`events.isEmpty`) renders `EventsMessageView(message: 'No upcoming events right now.')` with its default `showWebsiteLink: true`; `events_message_view.dart:36-57` — fallback link launches `ExternalLinks.eventsPage` via `UrlLauncherService` | `events_section_test.dart:205-235` (REQ-F08-016 group — message + link text + tap launches the correct URL + no pagination controls shown) | Pass |
| F08-017 | `events_section.dart:96-100` — `thisWeek.isEmpty` (but `events` non-empty) renders `EventsMessageView(message: 'No events this week.', showWebsiteLink: false)`, distinct from REQ-F08-016's message/link | `events_section_test.dart:241-258` (REQ-F08-017 group — distinct message, "More events >" control shown, no website fallback link) | Pass |
| F08-018 | `events_section.dart:63-68` — `error` branch renders a generic friendly message for any non-`EventsNetworkFailure` (i.e. `EventsParsingFailure`), with the default `showWebsiteLink: true` fallback link | `events_section_test.dart:261-274` (REQ-F08-018/019 group — parsing-failure case) | Pass |
| F08-019 | `events_section.dart:64-67` — `error is EventsNetworkFailure` branch renders a distinct "Couldn't connect..." message | `events_section_test.dart:276-288` (network-failure case, `findsOneWidget` for the distinguishable text) | Pass |
| F08-020 | `events_message_view.dart:41-43` — `onTap: () => ref.read(urlLauncherServiceProvider).launchExternal(...)`, never a no-op `onTap` | `events_section_test.dart:205-224` (tap launches via the fake launcher) | Pass |
| F08-021 | **Retired** (visualiser round 2, 2026-10-01, user-confirmed: "Yes, remove it and page inline by week (recommended)") — no "View all upcoming events" link exists; superseded by `_WeekPaginationBar`'s inline `More events >`/`< Back` controls (`events_section.dart:142-176`) | `events_section_test.dart` — the "Weekly pagination" group (lines 291-402) replaces the former REQ-F08-021 test | Retired |

### Event row actions

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-022 | `event_row.dart:61-122` — "Details" (`_ActionLink`) and "Add to my calendar" (`_AddToCalendarButton`) are two visually/spatially distinct tap targets stacked in a width-bounded corner column, each with `BoxConstraints(minHeight: 48, minWidth: 48)` (`:147`, `:191`) | No dedicated pixel-measurement test (`tester.getSize`); verified by direct code read of the literal `BoxConstraints` only — same precedent as this repo's other 48x48 requirements (e.g. 06-saint-of-the-day's REQ-F06-012, also "verified by code review, not unit-tested") | Pass (code-verified; no repo-wide precedent for automated touch-target-size tests) |
| F08-023 | `event_details_sheet.dart:18-28` — `showEventDetailsSheet` opens an in-app `showModalBottomSheet`, no `Navigator.push`/external navigation; `:78-104` renders title/displayTime/location/description from already-parsed `ParishEvent` fields only, no new network call; `:105-127` — optional secondary link rendered only when `event.detailUrl != null`; `:49-70` explicit "Close" tap target (plus the modal's own swipe-down/back-gesture defaults) | `events_section_test.dart:405-461` (REQ-F08-022/023 group — full content + website-link-present case, website-link-absent case, Close dismisses) | Pass |
| F08-024 | `presentation/utils/add_to_device_calendar.dart:14-32` — builds an `Event` from `event.title`/`description`/`location`/`start`/`end` and calls `ref.read(calendarExportServiceProvider).addEvent(...)` | `events_section_test.dart:465-497` (REQ-F08-024/025 group — asserts exact title/location/description/startDate/endDate reach the fake export service) | Pass (widget/fake-service level — **see RISK-013**: no live-device confirmation the native calendar app actually opens) |
| F08-025 | `calendar_export_service.dart:21-28` — `CalendarExportServiceImpl.addEvent` never throws (catches and returns `false`); `add_to_device_calendar.dart:34-43` — a `false` result shows an explicit `SnackBar`, never a silent no-op | `events_section_test.dart:499-519` (export-failure case shows the exact friendly message) + `:482-497` (default 1-hour-duration fallback when no `end`) | Pass |
| F08-026 | `events_section.dart` — "Details" opens an overlay (`showModalBottomSheet`) and "Add to my calendar" shows a `SnackBar`/calls the export service; neither triggers a `setState`/rebuild of `_EventsSectionState` or the enclosing scroll view | No dedicated scroll-position-preservation test; satisfied structurally (neither action touches `_weekIndex` or forces a list rebuild) — not called out as a required automated check in REQ-F08-039(a-g)'s own list | Pass (structural; no dedicated test, none required) |

### All Events screen (retired)

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-027 | `lib/features/events/presentation/screens/all_events_screen.dart` — deleted (`git rm`, visualiser round 2). `grep -rn "all_events_screen\|AllEventsScreen" lib/ test/` (this session) finds no route registration, no remaining screen file | N/A — screen and its test file (`all_events_screen_test.dart`) both deleted | Retired |
| F08-028 | Moot — no such screen exists | N/A | Retired |
| F08-029 | Moot — superseded by `EventsSection`'s own inline weekly pagination (`_weekIndex`, `_WeekPaginationBar`), which still satisfies the underlying intent (don't build the entire remaining list in one frame) by construction: only `thisWeek`'s events are ever added to the widget tree at once | `events_section_test.dart` "Weekly pagination" group indirectly confirms only the current week's rows render (e.g. line 296-302: "Next week" `findsNothing` while on week 0) | Retired (intent preserved by the replacement design) |
| F08-030 | Moot — `EventsSection` already is the one place reusing the loading/empty/error states and `EventRow`; there is no second screen to duplicate them | N/A | Retired |

### Integration, conventions & ADR

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-031 | `lib/features/news/presentation/screens/news_screen.dart:23-25` — `NewsHeroBanner()`, `EventsSection()`, `BulletinsSection()` in that exact order | Covered implicitly by `news_screen_test.dart`'s own ordering assertions (REQ-F05-031 group) — not re-asserted in events-specific tests, consistent with how cross-feature placement is verified elsewhere in this repo | Pass |
| F08-032 | **Amended** (visualiser round 3, 2026-10-01, user-confirmed: "Add a calendar icon too") — `event_row.dart:200-204` is now the app's one deliberate `Icon` (`Icons.calendar_month`, on "Add to my calendar"); every other tap target/action (`_ActionLink` "Details", `_WeekPaginationButton`, `EventsMessageView`'s links, the Details sheet's "Close"/website link) remains plain `Text`; `grep -rn "Icon(" lib/features/events/` (this session) shows exactly one call site. No emoji glyph anywhere — still fully required and unaffected | `events_section_test.dart:529-605` (REQ-F08-032 amended group — exactly 2 `Icons.calendar_month` for 2 rendered rows, no emoji regex match, zero icons in the empty/error state) | Amended (confirmed compliant with the amended wording) |
| F08-033 | `grep -rln "package:http\|RecurrenceRule\|add_2_calendar" lib/features/events/presentation/` (this session) — zero matches; all such logic lives in `data/datasources/`, `data/parsers/`, `data/repositories/`, and the thin `presentation/services/calendar_export_service.dart` wrapper (itself calling only the plugin, no parsing/network logic) | Structural — confirmed by direct read | Pass |
| F08-034 | `.claude/decisions/0006-events-ics-rrule-and-robots-scope.md` — read in full this session; documents the hand-rolled-parser-vs-package decision, the `RecurrenceRule.fromString` prefix finding, and the robots.txt disallow-scope reasoning, following the ADR-0004 precedent | N/A | Pass |

### UX / accessibility

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-035 | Same `BoxConstraints(minHeight: 48, minWidth: 48)` evidence as REQ-F08-022 (`event_row.dart:147,191`); visual separation: "Details" right-aligned above "Add to my calendar" with an explicit 4px gap, in a width-bounded (200px) corner column distinct from the title/location column | No dedicated pixel-measurement test — see REQ-F08-022's note; the `Flexible`-wrapped inner `Text` in `_AddToCalendarButton` was specifically added (see visualiser round 3 notes) to preserve this at large text scales | Pass (code-verified) |
| F08-036 | `event_row.dart`/`event_details_sheet.dart`/`events_message_view.dart`/etc. — every `Text` style is a named `textTheme.*` style (`labelMedium`, `titleMedium`, `bodySmall`, `bodyMedium`, `titleLarge`) with `.copyWith()` only for color/weight, never a raw `fontSize`; `grep -rn "fontSize:" lib/features/events/` (this session) returns no matches | No dedicated WCAG-contrast-ratio test (consistent with the rest of this repo — no automated contrast checker exists anywhere in this codebase); colors used (`AppColors.primaryNavy`/`textMuted` on white/navy) are the same tokens already relied on elsewhere | Pass (no raw small `fontSize`; contrast not automated, repo-wide pattern) |
| F08-037 | `event_row.dart`'s width-bounded corner column + `Flexible`-wrapped button text (added proactively during visualiser round 3, before asking the user to validate, specifically to prevent a `RenderFlex` overflow this exact change could have reopened) | `events_section_test.dart:607-716` (REQ-F08-037 group) — 3 screen sizes x 3 text scales (9 combinations) with a long title/location + both tap targets present, plus the empty-state sweep at 2.0x — all assert `tester.takeException()` is `null` | Pass |

### Quality gates

| Req | Code evidence | Test evidence | Status |
|---|---|---|---|
| F08-038 | User-confirmed clean `flutter analyze` + `dart format . --set-exit-if-changed` at the visualiser round 3 gate (2026-10-01) — this verifier phase could not re-run these itself (see "Command Re-Run" above) | N/A | Pass (re-stated, not independently re-run this phase) |
| F08-039 | (a) `ics_event_parser_test.dart` — parser fixtures, folding, RRULE expansion, malformed-skip, bad-RRULE-fallback. (b) `events_provider_test.dart` — loading/success/empty/network-failure/parsing-failure. (c) `parish_events_feed_live_test.dart` — real feed, resilient shape/field-validity assertions. (d) `events_section_test.dart`'s REQ-F08-024/025 and REQ-F08-022/023 groups — export-with-correct-data and Details-sheet-with/without-URL. (e) `events_section_test.dart`'s REQ-F08-014..020 groups plus the "Weekly pagination" group (the inline section's replacement for the retired All-Events-screen criteria). (f) the REQ-F08-032 (amended) group. (g) the REQ-F08-037 group | All sub-items (a)-(g) have corresponding test groups, enumerated above | Pass |

**Result: all 39 requirements have code evidence; 34 have direct test evidence; 5 (REQ-F08-021, 027-030) are retired/moot, documented above rather than silently dropped, with the underlying design intent (REQ-F08-029's "don't build the whole list in one frame") preserved by the replacement design and confirmed by its own tests. One item (REQ-F08-005) is only partially compliant with its literal wording — the past-event filter uses `start` alone in all three code paths rather than "end, falling back to start" — already caught and logged as RISK-012 during the Tester phase; independently re-confirmed unchanged this session, not a new finding. REQ-F08-022/026/035/036 are verified by direct code read rather than a dedicated automated test for their specific numeric/structural claim (touch-target size, scroll-position preservation, contrast ratio) — consistent with this repo's existing convention elsewhere (e.g. 06-saint-of-the-day's REQ-F06-012), not a new gap introduced by this feature.**

## RISK-003 / RISK-004 / RISK-005 Applicability Check

- `grep -rn "url_launcher\|UrlLauncher\|webview_flutter\|tel:\|mailto:" lib/features/events/` (this session) — two matches, both `https:`-scheme: `events_message_view.dart` (the fallback "View upcoming events on the parish website ↗" link, one code location shown in 3 UI states) and `event_details_sheet.dart` (the optional per-event "View on parish website ↗" secondary link). No `tel:`/`mailto:` usage.
- **RISK-003 and RISK-004 (Android `<queries>`/iOS `LSApplicationQueriesSchemes` gaps) extend to this feature** — same root cause as News' own addendum. Independently re-read `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` this session: both are unchanged (manifest still has only the `PROCESS_TEXT` `<queries>` entry; `Info.plist` still has no `LSApplicationQueriesSchemes` key). No addendum text added to either risk entry beyond this report, since the existing addenda already describe the exact same unresolved gap and fix; this feature does not introduce a new scheme type, only 2 more `https:` tap targets on top of the 12 already tracked.
- **RISK-005 (Android release-build `INTERNET` permission) already covers this feature** — confirmed via direct re-read of `android/app/src/main/AndroidManifest.xml:4` (the permission is present, unscoped by host) that this feature's feed fetch (`parish_events_feed_datasource.dart`, a fourth direct `http.Client` network-calling surface after Donate/News/Saint-of-the-Day) is already covered. No new gap; no manifest change required.

## New Risk Found This Phase — RISK-013

Across all three visualiser live-feedback rounds, every piece of user feedback was about the row's/button's **visual appearance** (size, label, icon) on a real Android emulator — never about tapping "Add to my calendar" and confirming the native calendar app actually opens, pre-filled with the event's title/time/location/description. REQ-F08-024's actual behavior (the plugin call to `add_2_calendar`) is currently verified only against a fake `CalendarExportService` in `events_section_test.dart` — a deliberate, correct test-design choice (same precedent as `UrlLauncherService`'s own fake-override tests) that, exactly like RISK-003's root cause, cannot by itself catch a real platform-integration failure (e.g. a missing Android `<queries>`/intent-resolution entry for the calendar app, or an iOS `EventKitUI` permission prompt behaving unexpectedly). Neither `android/app/src/main/AndroidManifest.xml` nor `ios/Runner/Info.plist` declares anything calendar-related, which is consistent with `add_2_calendar`'s documented approach (it opens the native Calendar app's own "add event" UI rather than writing to the calendar database directly, so no `READ_CALENDAR`/`WRITE_CALENDAR` permission is expected) — but this has not been positively confirmed by an actual on-device tap, only inferred from the plugin's intended design. Logged as **RISK-013** in `.claude/risks/active-risks.md`, per the verifier-agent's rule to log, not just narrate, any risk found during traceability review.

## RISK-012 — Re-Confirmed, Not New

Independently re-read `ics_event_parser.dart:196-225` this session: the past-event filter still compares `start` alone in all three branches (plain single-occurrence, RRULE-fallback, and the `rule.getInstances(after: now, ...)` call itself), exactly as RISK-012 describes. No code change has touched this file since the Tester phase logged it. Carried forward as-is; no addendum needed, status remains **open**.

## Unresolved / Carried-Forward Gaps (not new, restated for completeness)
- **RISK-013 (new, this phase)** — no live-device confirmation that "Add to my calendar" opens the native calendar app. See above.
- **RISK-012 (carried forward, open)** — past-event filter uses `start` alone, not "end, falling back to start" per REQ-F08-005's literal wording; a currently-in-progress recurring event briefly disappears for its own duration.
- RISK-003/RISK-004 (Android `<queries>`/iOS `LSApplicationQueriesSchemes` external-link gaps) now cover 14 tap targets project-wide (12 before this feature + 2 new `https:` links here) — unresolved, tracked via GitHub issue #12.
- REQ-F08-022/026/035/036 are verified by code read rather than a dedicated automated test for their specific claim — consistent with this repo's existing convention, not new to this feature.
- No golden/visual regression tests — consistent with the still-open, documented gap across every prior feature in this repo.
- This verifier phase could not independently re-run `flutter analyze`/`dart format`/`flutter test` itself (no Flutter SDK reachable) — relies on the user's own confirmed clean re-run from the visualiser round-3 gate instead.
- The visualiser phase's three live-feedback rounds (plus the round-2.5 tweak pass) were a deliberate, user-authorized deviation from this repo's default no-rework-loop/file-as-issue procedure, documented transparently in the visualiser plan at each round. This verifier phase assesses that deviation as sound: each round was explicitly surfaced to and confirmed by the user before implementation (via direct restatement or `AskUserQuestion`), each was committed only after clean pasted validation evidence, and the net result is a materially better, still-fully-traceable feature rather than a procedural shortcut.

## Verdict

**Conditional pass.**

All 39 requirements (REQ-F08-001..039) are implemented with complete, independently-verified traceability — 34 with direct code + test evidence, 5 (REQ-F08-021, 027-030) correctly retired/moot with the replacement design's own tests covering the preserved intent, and REQ-F08-032 correctly amended with its own updated test group. No missing evidence, no mismatches between the coder/tester/visualiser plans' self-reports and the actual code. RISK-003/RISK-004's scope extension and RISK-005's continued coverage are both confirmed, not newly broken. RISK-012 is re-confirmed unchanged and still open.

The conditional element is threefold, none of which is a functional defect found in this feature's actual implementation: (1) this verifier phase could not independently re-run the validation commands itself, relying instead on the user's own confirmed clean round-3 re-run; (2) REQ-F08-005's known, already-logged RISK-012 gap remains open and unfixed, by deliberate choice (the correct fix needs recurrence-timing logic this session cannot verify by execution); and (3) the newly-logged RISK-013 — a real, non-blocking gap in live functional verification for this feature's primary distinguishing action ("Add to my calendar"), never a code defect, since the implementation matches the plugin's documented usage and is fully covered at the widget/fake-service level. Recommend the user do one more `flutter analyze`/`dart format`/`flutter test` pass immediately before Deployer/PR, and recommend an explicit live tap-through of "Add to my calendar" on a real Android/iOS device during the Deployer phase (or before) to close RISK-013, alongside the existing RISK-003/004/005 live-verification work already expected for that phase.
