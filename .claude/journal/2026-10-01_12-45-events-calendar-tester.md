# Journal Entry

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Phase: tester
- Timestamp: 2026-10-01_12-45

## Files Changed
- Added: `test/features/events/presentation/providers/events_provider_test.dart` (provider-level `AsyncValue` state tests).
- Added: `test/features/events/data/datasources/parish_events_feed_live_test.dart` (live integration test against the real feed).
- Added: `test/features/events/presentation/widgets/events_section_test.dart` (inline-section widget tests: states, per-row actions, no-icon/emoji sweep, overflow sweep).
- Added: `test/features/events/presentation/screens/all_events_screen_test.dart` (full-list/pagination/back-navigation widget tests).
- Added: `lib/features/events/presentation/services/calendar_export_service.dart` (new injectable `CalendarExportService` abstraction, mirroring `UrlLauncherService`).
- Modified: `lib/features/events/presentation/utils/add_to_device_calendar.dart` (now takes a `WidgetRef` and calls through `calendarExportServiceProvider` instead of `Add2Calendar.addEvent2Cal` directly).
- Modified: `lib/features/events/presentation/widgets/events_section.dart`, `lib/features/events/presentation/screens/all_events_screen.dart` (both call sites pass `ref` through to `addEventToDeviceCalendar`).
- Modified: `.claude/risks/active-risks.md` (new RISK-012).
- Added: `.claude/plans/tester/2026-10-01_12-45-events-calendar.md`, this journal.

## Commands Run
- None (`flutter`/`dart` unavailable in this session's environment — same constraint as this feature's own coder phase). All verification was by reading `lib/features/events/` source directly against each REQ-F08-* acceptance criterion, and all new test code was written by reading the existing widgets/entities directly, not run.

## Results
- Independently re-verified all 39 requirements against the actual implementation (not the coder plan's self-report) — full traceability, one genuine gap found: REQ-F08-005's past-event filter compares `start` alone in all three parser code paths, where the requirement specifies falling back to `start` only when no `end`/duration is known. Logged as RISK-012 rather than fixed blind, since the correct fix touches recurrence-expansion timing logic this session cannot verify by execution.
- Found and closed a testability gap: `add_to_device_calendar.dart` called the `add_2_calendar` plugin statically with no injectable seam, unlike every other external-effect call site in this app. Added `CalendarExportService` (mirroring `UrlLauncherService`'s exact shape) and threaded `WidgetRef` through both call sites so "Add to my calendar" is now testable with a fake, closing REQ-F08-039(d).
- Closed the remaining REQ-F08-039 sub-items the coder plan explicitly deferred: (b) provider-level `AsyncValue` states, (c) a live integration test, (d) Details-sheet/Add-to-calendar behavior, (e) `EventsSection`/`AllEventsScreen` widget tests, (f) a no-icon/emoji sweep exercised against real rendered event content (the pre-existing `news_screen_test.dart` sweep only exercised Events in its empty state), (g) the REQ-F08-037 text-scale/screen-size overflow sweep.

## Risks / Follow-up
- **This session could not run `flutter analyze`, `dart format .`, or `flutter test`** — no Flutter SDK in this environment. None of the 4 new test files or the `CalendarExportService` refactor have been executed. Same mitigation as the coder phase: ask the user to run the validation commands locally and report back before this phase is approved and committed.
- RISK-012 (new): events whose start has passed but whose end hasn't are excluded from the upcoming list; low severity, recommended as a small follow-up fix, not blocking.
- Unresolved, lower-priority gaps carried forward (not closed this phase): no `MockClient`-based unit test for `ParishEventsFeedDatasource` itself (the `bulletins_feed_datasource_test.dart` precedent); the new live events test isn't offline/CI-isolated (same class as the pre-existing RISK-007); no golden-image tests (pre-existing, app-wide, deliberately deferred since 01-bootstrap-app).

## Next Handoff
- Stopping here per tester-agent rules. **Not requesting the normal "review the code" approval alone** — asking the user to also run `flutter analyze`/`dart format . --set-exit-if-changed`/`flutter test` locally and report back pass/fail, and to review the `CalendarExportService` refactor and the new test files, before this phase is approved and committed.
