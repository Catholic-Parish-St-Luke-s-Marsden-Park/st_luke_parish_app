# VISUALISER_AGENT Plan

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Phase: visualiser
- Timestamp: 2026-10-01_12-58

## Inputs
- Approved tester plan: `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`
- Tester commit under test: `5ceac53`
- Root `CLAUDE.md` (Android and iOS are the only supported targets)

## Environment Constraint
This session's own environment (a sandboxed bridge VM linked to the user's Windows machine) has no Flutter SDK and no Android/iOS tooling at all — confirmed this phase via `which flutter dart gh` (all not found). The same constraint applied to every prior phase this feature (Coder, Tester): the live run has to happen on the user's own machine, with the user reporting results back. An iOS Simulator additionally requires macOS/Xcode, which this Windows machine cannot run at all, regardless of tooling.

## Platform Decision (user choice, this phase)
- Asked the user directly which platform(s) to preview (per this agent's own rule to never assume). Chosen: **Android now; iOS deferred** — the user confirmed this Windows machine can't run an iOS Simulator directly and chose "Android only for now," logging the iOS live-render check as an open item rather than blocking on finding/using a separate Mac. This mirrors the precedent set by 01-bootstrap-app's RISK-002 (deferred Android live-run, later resolved) and 04-masses-tab's RISK-006 (deferred live-render sign-off, carried forward by user choice).

## Procedure
1. Asked the user which platform(s) — see Platform Decision above.
2. Could not check/boot a simulator/emulator myself (no `flutter`/`adb` in this session's environment) — handed the user exact commands to run on their own machine instead (see below).
3. Awaiting the user to run the app and report hands-on feedback on the News tab's new "Upcoming Events" section and the "View all upcoming events" screen.

## Commands Handed to the User
`flutter emulators` showed one available Android emulator: `Pixel_9` (Google Pixel 9). Handed the user the concrete follow-up commands:
```
cd C:\dev\st_luke_parish_app
flutter emulators --launch Pixel_9
flutter run -d emulator-5554
```
(Not the `Medium_Phone_API_36.1`/`emulator-5554` AVD referenced in this project's earlier 06-saint-of-the-day/01-bootstrap-app sessions — a different AVD, `Pixel_9`, now exists on this machine instead; `emulator-5554` is simply the first-launched Android emulator's standard ADB device id, reused here by convention, confirmed once `flutter run` actually lists its target devices.)

## Checklist Given to the User
1. Open the News tab — does "Upcoming Events" appear above "Latest Bulletins", with a short loading moment then real events (or an appropriate empty/error message if the feed is genuinely empty right now)?
2. Do rows show a navy date/time pill, bold title, and (when the event has one) an italic location line — with no icons or emoji anywhere?
3. Tap "Details" on a row — does an in-app bottom sheet open (not a browser) with the event's title/time/location/description, and (when present) a "View on parish website ↗" link that opens externally? Does "Close" dismiss it?
4. Tap "Add to my calendar" on a row — does it open your device's Calendar app pre-filled with that event?
5. Tap "View all upcoming events" — does it open a full paginated list, with a "Load more" button if there are enough events, and does the system/app-bar back button return cleanly to the News tab?
6. Rotate/resize if convenient, or just eyeball it at normal size — anything visually broken, cut off, or misaligned?

## Next Handoff
- Awaiting the user's hands-on feedback (may span multiple messages). Once given, defects will be parsed into a distinct list, shown back to the user for confirmation, and — only with explicit confirmation — filed as GitHub issues (this session also has no `gh` CLI or push credentials, so issue filing will likewise need the user's own terminal/browser, same as every git-touching step this session).
- iOS live-render check logged as an open item per the Platform Decision above, to be reflected in a new risk entry once this phase closes.

## Live Feedback (Android, Pixel_9 emulator)
User ran the app live on the `Pixel_9` Android emulator per the checklist above and reported two issues from screenshots of the News tab's "Upcoming Events" section:

1. **Row layout too tall.** Verbatim: "too big blocks , should be 2 lines worth date and the event sizing is good put the details and add to my calendar to the other corner so the block size will be small and make the add to my calendar look like a button." Parsed and confirmed with the user as: the per-row actions ("Details" / "Add to my calendar") were rendered as a `Wrap` that stacked as separate full-width-looking lines, making each row far taller than the ~2-line date/title/location content alone needed; the fix is to group both actions compactly in the row's top-right corner and style "Add to my calendar" as a visually distinct small filled button (unlike "Details", left as a plain text link).
2. **No real pagination.** Verbatim: "yes also no pagination just says view all events and just keeps loading more - should ideally give a forward back arrow (back arrow only if the user is looking at the future events)." Parsed and confirmed: the All Events screen's cumulative "Load more" button (REQ-F08-029's original design) grows the visible list indefinitely with no way back to earlier events; the fix is forward/back page navigation instead, with the "Back" control appearing only once the user has paged forward past the first page (page 0, the soonest upcoming events, has nothing earlier to go back to).

## Deviation From Default No-Rework-Loop Procedure
This agent's own default rule (see `.claude/agents/visualiser-agent.md`) is "no rework loop" at this phase: confirmed defects are normally filed as GitHub issues (not fixed), and approval at this gate means "the preview happened and feedback was captured/filed," not "all defects are fixed." This session also has no `gh` CLI and no GitHub push credentials, so issue filing would itself have required handing the user manual `gh issue create` commands to run themselves.

After the two defects above were parsed and confirmed with the user, the user explicitly instructed: **"ok fix the issues"** — a direct instruction to implement both fixes now, overriding the default procedure. Per the instruction-source rules, this is a valid override (an explicit user instruction in this session, not content from any external/observed source), so both fixes were implemented directly in this phase rather than filed as GitHub issues. This deviation is recorded here for traceability.

## Fixes Applied
1. **`lib/features/events/presentation/widgets/event_row.dart`** — rewritten: `Row` with the date/time pill + bold title + italic location in an `Expanded` left column, and "Details" (plain text link) + "Add to my calendar" (small filled navy pill button, `Material`+`InkWell`+`Container`) stacked and right-aligned in a width-bounded (120px) corner column on the right. The 120px bound keeps both REQ-F08-035's 48x48 minimum tap targets and REQ-F08-037's overflow-free reflow at 2x text scale: the button's `Text` wraps onto a second line at large scales instead of growing unboundedly and starving the left column's width inside the `Row`. No `Icon`/emoji used (REQ-F08-032 preserved).
2. **`lib/features/events/presentation/screens/all_events_screen.dart`** — `_visibleCount`/`_LoadMoreButton` replaced with a `_pageIndex`-based page model (`pageStart = _pageIndex * _pageSize`, `visible = events.skip(pageStart).take(_pageSize)`, `hasNext`/`hasPrevious`) and a new `_PaginationBar` footer with `< Back` / `Next >` plain-text controls (ASCII glyphs, not `Icon` widgets, consistent with REQ-F08-032's no-icon convention). "Back" only renders when `hasPrevious` (i.e. `_pageIndex > 0`), per the user's explicit requirement.
3. **`test/features/events/presentation/screens/all_events_screen_test.dart`** — REQ-F08-029 group rewritten: the two "Load more" tests replaced with four tests covering first-page "Next"-only state, second-page "Back"-appears/first-page-events-gone state, "Back" returning to the first page, and the single-page (no controls) case.

Both changes verified for balanced braces/parens/brackets and re-read in full after writing, but not yet compiled/run — pending the user's own `flutter analyze` / `dart format` / `flutter test` validation, per this project's standing rule not to commit without the user's own clean local evidence.

## Round 2: Further Live Feedback (still Android, Pixel_9 emulator)
After the round-1 fixes above were committed, the user re-ran the app live and reported two more issues from a fresh screenshot of the News tab:

1. **"Add to my calendar" still too big.** Verbatim: "still looks ugly probably the add to my calendar button is too big." The filled navy pill button from round 1 was wrapping onto two lines ("Add to my", "calendar") at normal text scale within the 120px-bounded corner column, making it visually dominant and bulky -- the opposite of the "small button" originally asked for.
2. **Remove the separate full-list screen; page inline by week instead.** Verbatim: "also view all upcoming events - do we need this? cant we just have next ? and when the user hot next it just shows the next weeks events and the back arrow will also activated so the users can navigate within the same screen section."

Both were parsed and shown back to the user for confirmation via two explicit questions before any code was touched:
- **Button fix**: offered "shrink to a compact single-line pill" vs. an open "something else" option. The user chose the open option, answering **"plain text link would do"** -- i.e. drop the filled-button treatment entirely and give "Add to my calendar" the same plain-text-link styling as "Details", rather than trying to shrink the filled pill further.
- **Pagination scope**: offered "remove `AllEventsScreen` entirely and page inline by week (recommended)" vs. "keep the screen, just unlink it for now." The user chose **"Yes, remove it and page inline by week (recommended)"**.

This second round required reopening and redesigning files already committed in round 1 (`event_row.dart` again, plus `events_section.dart` and `all_events_screen.dart` this time), continuing under the same "ok fix the issues" authorization and the same deviation from the default no-rework-loop procedure recorded above -- the user's confirmation of these two parsed items in this round is the equivalent explicit go-ahead for this round's work.

## Round 2 Fixes Applied
1. **`lib/features/events/presentation/widgets/event_row.dart`** -- the filled `_AddToCalendarButton` pill is removed; both "Details" and "Add to my calendar" now share one `_ActionLink` plain-text-link treatment (right-aligned, bold navy `Text`, same 48x48 minimum tap target). The corner column's width bound was widened from 120px to 170px (bodyMedium is a wider font than the old button's bodySmall) so "Add to my calendar" fits on one line at normal text scale instead of wrapping -- still bounded, so REQ-F08-037's overflow-free reflow at 2x text scale still holds (the text simply wraps at large scales instead of forcing a `RenderFlex` overflow).
2. **`lib/features/events/presentation/widgets/events_section.dart`** -- converted from `ConsumerWidget` to `ConsumerStatefulWidget` with a `_weekIndex` page-state variable. The inline "Upcoming Events" section now pages through the full upcoming-events list a week at a time (`now + 7*weekIndex` .. `now + 7*(weekIndex+1)`), with a new `_WeekPaginationBar`/`_WeekPaginationButton` footer (`< Back` / `Next >`, plain-text ASCII glyphs, consistent with REQ-F08-032's no-icon convention) replacing the old `_ViewAllLink`. "Back" only renders once `_weekIndex > 0`. An empty week (no events fall in the current window) shows a "No events this week." message but still renders the pagination bar when there are events further out, so the user can keep paging forward past a quiet week.
3. **`lib/features/events/presentation/screens/all_events_screen.dart`** and **`test/features/events/presentation/screens/all_events_screen_test.dart`** -- both deleted (`git rm`). No other file referenced the screen outside doc comments (verified via a full `AllEventsScreen`/`all_events_screen` grep sweep across `lib/` and `test/`); the only remaining mentions are historical doc-comment notes (in `events_section.dart`, `events_section_test.dart`, and the generated `events_provider.g.dart`, which will re-sync its doc comment on the user's next `build_runner build` -- the cosmetic generated-file drift already known from this session's `.g.dart` precedent) explaining why the screen no longer exists.
4. **`lib/features/events/presentation/providers/events_provider.dart`** -- doc comment updated to no longer describe `AllEventsScreen` as a second consumer of `upcomingEventsProvider`.
5. **`test/features/events/presentation/widgets/events_section_test.dart`** -- rewritten: the former REQ-F08-021 group ("navigates to AllEventsScreen") is replaced with a new "Weekly pagination" group (5 tests: first-week Next-only state, Next reveals next week + Back, Back returns to first week, no controls when everything fits in the first week, an empty middle week still allows paging further forward to reach a week-3 event). REQ-F08-016's "does not show the View all upcoming events link" test is renamed/generalised to assert no pagination controls in the fully-empty state. REQ-F08-017's empty-this-week test now checks for "No events this week." and a "Next >" control instead of the old message/link text.

## Requirement Changes (superseding the original BA plan)
This redesign retires requirements the original BA plan (`.claude/plans/ba/2026-10-01_11-15-09-events-calendar.md`) wrote around a separate full-list screen, specifically:
- `REQ-F08-021` ("View all upcoming events" link navigating to the All Events screen) -- superseded by inline `_WeekPaginationBar` Next/Back controls within `EventsSection` itself.
- `REQ-F08-027`..`REQ-F08-030` (the All Events screen's own reachability, full-list rendering, pagination, and shared-state-reuse requirements) -- moot; the screen no longer exists.

All other REQ-F08-0xx requirements (parsing, Details sheet, calendar export, no-icon convention, overflow sweep, etc.) are unaffected. This is flagged here for the Verifier phase's traceability pass, since the original BA plan document itself is left as the historical record and not retroactively edited.

Both files verified for balanced braces/parens/brackets and re-read in full after writing; not yet compiled/run -- pending another round of the user's own `flutter analyze` / `dart format` / `flutter test` validation.

## Round 3: Reference-Image Feedback (Add to Calendar button style)
After round 2's commit, the user re-ran the app live, reported "happy to move forward" on the pill-size/label tweaks, then shared a reference screenshot of a rail-journey app's "Add to Calendar" button (an outlined pill with a calendar icon) and asked: "can add to my calendar be like this?"

This raised a direct conflict with REQ-F08-032 ("No `Icon` widget and no emoji glyph is rendered anywhere... consistent with the rest of the app's no-icon convention"), a rule enforced by automated tests in every feature since 01-bootstrap-app. Rather than silently either ignore the reference image's icon or silently break an app-wide convention, this was surfaced explicitly and confirmed before any code changed: offered "outlined pill, text only (recommended)" (matching the reference's shape without its icon, staying within the existing rule) vs. "add a calendar icon too" (breaking the no-icon convention for this button specifically, requiring the REQ-F08-032 tests to be updated). The user chose **"Add a calendar icon too"**.

This is the first `Icon` widget anywhere in this app's codebase. It is treated as a deliberate, explicit, user-confirmed exception -- not a silent regression -- and documented here for the Verifier phase's awareness.

## Round 3 Fixes Applied
1. **`lib/features/events/presentation/widgets/event_row.dart`** -- "Add to my calendar" is now `_AddToCalendarButton`: an outlined pill (white fill, 1px navy border, rounded corners) with a `Icons.calendar_month` icon (16px, navy) followed by the label text, matching the reference screenshot's shape. "Details" is unchanged (`_ActionLink`, plain text). The action column's width bound widened 170px -> 200px to comfortably fit the icon+label on one line at normal text scale. The button's inner `Text` is wrapped in `Flexible` -- a bare `Text` as a direct child of a `Row` (as opposed to a direct child of a width-bounded `Container`, which is what the previous plain-text-link version relied on) is given *unbounded* main-axis width by Flutter's Flex layout and will not wrap on its own, which would have reopened the exact `RenderFlex` overflow risk the 200px bound exists to prevent at large text scales (REQ-F08-037). This was caught and fixed during implementation, before asking the user to validate.
2. **`test/features/events/presentation/widgets/events_section_test.dart`** -- the REQ-F08-032 group and the file's header doc comment are both updated: the "no Icon widget is rendered with real event content" test now asserts exactly one `Icons.calendar_month` icon per rendered event row (`find.byIcon(Icons.calendar_month), findsNWidgets(n)`) instead of asserting no icons at all. The "no emoji glyph" and "empty/error state has no icon" tests are unchanged -- emoji are still fully disallowed, and an empty/error state (no event rows rendered) still has zero icons.
3. Verified via a full-suite grep that no OTHER test file's "no Icon" sweep is affected: `news_screen_test.dart`'s own REQ-F05-030 "no Icon" tests always override `eventsRepositoryProvider` with an empty events list (its own default `pumpNewsScreen` helper), so `EventsSection` never renders a populated event row -- and therefore never an icon -- in that file's test scenarios. No app-wide/cross-feature icon sweep exists outside each feature's own screen-level test file.

## Requirement Amendment (REQ-F08-032)
`REQ-F08-032` ("No `Icon` widget and no emoji glyph is rendered anywhere... 'Details' and 'Add to my calendar' are `Text`, not `Icon`, widgets") is amended as of this round: the calendar glyph on "Add to my calendar" is now an explicit, user-confirmed exception. The "no emoji glyph anywhere" half of the requirement is unaffected and still holds in full; every other tap target and action in both this feature and the rest of the app remains plain `Text`. This is flagged here, alongside the REQ-F08-021/027..030 changes recorded in Round 2 above, for the Verifier phase's traceability pass.

Verified for balanced braces/parens/brackets and re-read in full after writing; not yet compiled/run -- pending the user's own `flutter analyze` / `dart format` / `flutter test` validation.

