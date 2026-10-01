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

