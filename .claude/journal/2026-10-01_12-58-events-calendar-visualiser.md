# Journal Entry

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Phase: visualiser
- Timestamp: 2026-10-01_12-58

## Files Changed
- Modified: `lib/features/events/presentation/widgets/event_row.dart` (compact corner-grouped actions, "Add to my calendar" styled as a small filled button).
- Modified: `lib/features/events/presentation/screens/all_events_screen.dart` (`_visibleCount`/`_LoadMoreButton` replaced with `_pageIndex`-based forward/back pagination, new `_PaginationBar`/`_PaginationButton`).
- Modified: `test/features/events/presentation/screens/all_events_screen_test.dart` (REQ-F08-029 group rewritten for forward/back behaviour instead of "Load more").
- Modified: `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md` (live feedback, confirmed defects, deviation note, fixes-applied section appended).
- Added: this journal.

## Commands Run
- None directly (`flutter`/`dart` unavailable in this session's environment, same constraint as every prior phase this feature). The user ran the app live on their own Android emulator (`Pixel_9`) per the checklist handed to them in this phase's plan, and reported feedback from the running app plus screenshots.

## Results
- Live Android run surfaced two real UI defects not caught by any Coder/Tester-phase automated test (those only assert text presence/tap behaviour, not visual compactness or page-vs-cumulative-list semantics) -- exactly the class of gap this phase exists to catch.
- Defects parsed from the user's feedback and shown back for confirmation before any action: (1) per-row actions rendered as a tall `Wrap`, needed to be a compact top-right corner group with "Add to my calendar" as a button; (2) "View all upcoming events" used a cumulative "Load more" button instead of real forward/back page navigation.
- User explicitly instructed **"ok fix the issues"**, overriding this agent's own default "no rework loop / file as GitHub issues" procedure (this session also has no `gh` CLI or push credentials, so issue filing would have needed the user's own terminal regardless). Both fixes were implemented directly per that explicit instruction; see "Deviation From Default No-Rework-Loop Procedure" in the plan for the full reasoning.
- `event_row.dart` rewritten with the right-side actions column bounded to a fixed 120px width, specifically so "Add to my calendar"'s text wraps rather than grows unboundedly at large text scales -- preserves REQ-F08-037 (no-overflow reflow sweep) and REQ-F08-035 (48x48 minimum tap targets) under the new layout.
- `all_events_screen.dart` rewritten with page-index state; "Back" only renders when `_pageIndex > 0`, per the user's explicit "back arrow only if the user is looking at the future events" requirement.
- `all_events_screen_test.dart`'s REQ-F08-029 group rewritten: 2 "Load more"-based tests replaced with 4 tests (first-page Next-only, second-page Back-appears/first-page-events-gone, Back-returns-to-first-page, single-page-no-controls).
- All three edited/rewritten files re-read in full after writing and checked for balanced braces/parens/brackets; none has been compiled or executed.

## Risks / Follow-up
- **Not yet validated**: no `flutter analyze`, `dart format`, or `flutter test` run against these changes. Same mitigation as every prior phase -- asking the user to run the three validation commands locally and report back before committing.
- `events_section_test.dart` was re-examined (not modified) for compatibility with the new `event_row.dart` layout, specifically its REQ-F08-037 overflow sweep at `smallPhoneSize` (360dp) with `TextScaler.linear(2.0)`: the new 120px-bounded action column was deliberately sized to keep the `Row` overflow-safe at that combination (the only non-flexible-width sibling to the `Expanded` title/location column), but this reasoning has not been confirmed by an actual test run.
- iOS live-render check remains deferred (per the Platform Decision in this phase's plan, carried from before this round of fixes) -- still an open item, not reflected in a risk entry yet.

## Next Handoff
- Asking the user to re-run `flutter analyze` / `dart format . --set-exit-if-changed` / `flutter test` locally on these changes and report back pass/fail, before this phase is committed -- same two-step (write -> validate -> commit) pattern used for every prior phase this feature.
- Once validation is clean: commit, update `feature-index.md` and `memory.md`'s Active State header, then determine next handoff (presumably further live confirmation of the fixes from the user, then on to Verifier).

## Round 2 Addendum (same phase, further live feedback)

### Files Changed (round 2)
- Modified: `lib/features/events/presentation/widgets/event_row.dart` (filled "Add to my calendar" button replaced with a shared plain-text `_ActionLink`, matching "Details"; corner column widened 120px -> 170px).
- Modified: `lib/features/events/presentation/widgets/events_section.dart` (converted to `ConsumerStatefulWidget`; inline weekly pagination with `_WeekPaginationBar` replaces the old "View all upcoming events" link).
- Modified: `lib/features/events/presentation/providers/events_provider.dart` (doc comment no longer references `AllEventsScreen`).
- Modified: `test/features/events/presentation/widgets/events_section_test.dart` (new "Weekly pagination" group; REQ-F08-016/017 assertions updated for the new controls/messages).
- Deleted: `lib/features/events/presentation/screens/all_events_screen.dart`.
- Deleted: `test/features/events/presentation/screens/all_events_screen_test.dart`.
- Modified: `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md` (Round 2 feedback, fixes, and requirement-change sections appended).

### Results (round 2)
- User re-ran the app live after round 1's commit and reported the filled "Add to my calendar" button still looked too large (wrapping to two lines at normal text scale), and asked whether the separate "View all upcoming events" screen was needed at all, proposing inline Next/Back weekly paging within the News tab section instead.
- Both items parsed and confirmed via explicit questions before any code was touched (see plan's "Round 2" section for the exact options and the user's answers): "plain text link would do" for the button (not a smaller filled button -- drop the filled treatment entirely), and "Yes, remove it and page inline by week" for pagination.
- `all_events_screen.dart` and its test file are fully deleted, not just unlinked, per the user's explicit choice. A full grep sweep across `lib/` and `test/` confirmed no remaining code references outside historical doc comments (one of which is in the generated `events_provider.g.dart`, a known cosmetic doc-comment-drift case from this session's existing `.g.dart` precedent, not a functional issue).
- This retires the original BA plan's `REQ-F08-021` and `REQ-F08-027..030` (the separate-screen requirements) -- documented explicitly in the plan's "Requirement Changes" section for the Verifier phase's traceability pass, since the BA plan document itself is left as the unedited historical record.
- All three edited files and the two deletions re-checked (balanced braces/parens/brackets on the edited files; a full grep sweep confirming no dangling references) after writing; none has been compiled or executed yet.

### Risks / Follow-up (round 2)
- Same as round 1: **not yet validated** -- no `flutter analyze`/`dart format`/`flutter test` run against this round's changes. Asking the user to re-run the three commands and report back before committing.
- The generated `events_provider.g.dart` still carries a stale doc-comment mention of `AllEventsScreen` (comment-only, no functional impact) until the user's next `dart run build_runner build` -- consistent with this session's existing cosmetic `.g.dart` drift pattern, not treated as a new risk entry.

### Next Handoff (round 2)
- Asking the user to re-run `flutter analyze` / `dart format . --set-exit-if-changed` / `flutter test` locally and report back pass/fail before this round is committed.
- Once validation is clean: commit, update `feature-index.md` and `memory.md` again, then get one more live look from the user to confirm the plain-text "Add to my calendar" link and the new weekly Next/Back paging look and behave as expected before moving to Verifier.

## Round 3 Addendum (same phase, reference-image feedback)

### Files Changed (round 3)
- Modified: `lib/features/events/presentation/widgets/event_row.dart` ("Add to my calendar" restyled to an outlined pill with a calendar icon; "Details" unchanged; action column widened 170px -> 200px).
- Modified: `test/features/events/presentation/widgets/events_section_test.dart` (REQ-F08-032 group and header doc comment updated for the confirmed icon exception).
- Modified: `.claude/plans/visualiser/2026-10-01_12-58-events-calendar.md` (Round 3 feedback, fix, and requirement-amendment sections appended).

### Results (round 3)
- User shared a reference screenshot of a rail-journey app's outlined "Add to Calendar" button (calendar icon + text) and asked whether "Add to my calendar" could look like it.
- This conflicted directly with REQ-F08-032's no-Icon-widget convention, enforced by automated tests since 01-bootstrap-app -- surfaced explicitly via two options (text-only outlined pill matching the shape but not the icon, vs. breaking the convention) before writing any code. The user chose to add the icon.
- This is the first `Icon` widget in this app's codebase. Implemented as `_AddToCalendarButton`: outlined pill (white fill, navy 1px border), `Icons.calendar_month` + label, matching the reference's shape.
- Caught and fixed an overflow risk during implementation itself (before asking the user to validate): a bare `Text` as a direct child of a `Row` gets unbounded main-axis width in Flutter's Flex layout and will not wrap, unlike the previous design where `Text` was a direct child of a width-bounded `Container`. Wrapped the button's `Text` in `Flexible` to restore REQ-F08-037's overflow-free behaviour at large text scales.
- Updated the REQ-F08-032 test group to assert exactly one `Icons.calendar_month` icon per event row instead of asserting none. Verified via a full grep sweep that no other test file's "no Icon" assertions are affected (`news_screen_test.dart`'s own sweep always renders `EventsSection` with zero events, so it never exercises a populated row).
- Noticed `lib/features/masses/data/config/static_mass_schedule_config.dart` also shows as locally modified (an added weekday Mass entry) -- unrelated to this feature, left untouched and out of this round's commit.

### Risks / Follow-up (round 3)
- Same as rounds 1-2: **not yet validated** -- no `flutter analyze`/`dart format`/`flutter test` run against this round's changes.
- REQ-F08-032 is now a precedent exception (first-ever Icon in the app) -- documented explicitly in the plan rather than left implicit, since a future feature's BA/Coder phase reading the old "no Icon anywhere" wording verbatim would be factually wrong without this note.

### Next Handoff (round 3)
- Asking the user to re-run `flutter analyze` / `dart format . --set-exit-if-changed` / `flutter test` locally and report back pass/fail before this round is committed.
- Once validation is clean: commit, update `feature-index.md` and `memory.md`, then get one more live look to confirm the new "Add to my calendar" button renders as expected before moving to Verifier.
