import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/events/data/datasources/parish_events_feed_datasource.dart';
import 'package:st_luke_parish_app/features/events/data/parsers/ics_event_parser.dart'
    show sydneyNowAsFakeUtc;
import 'package:st_luke_parish_app/features/events/data/repositories/feed_events_repository.dart';

/// Live integration test against the real parish site's AI1EC calendar
/// export feed, per CLAUDE.md's scraping test rules ("Live integration
/// tests ... are allowed and expected for scraping verification. Do not
/// rely only on mocked HTML") and REQ-F08-039(c). Mirrors
/// `bulletins_feed_live_test.dart`'s structure and the same RISK-007
/// caveat (requires real network access; not offline/CI-isolated).
///
/// Requires network access — if this fails in an offline/sandboxed CI
/// environment, that is an environment limitation, not necessarily a code
/// defect; the fixture-based unit tests in `ics_event_parser_test.dart`
/// provide network-independent coverage of the parsing/expansion logic
/// itself.
///
/// Assertions are intentionally resilient (shape/field-validity checks)
/// rather than asserting exact event titles/dates/counts, since the live
/// feed's real content (and which Masses/groups are currently scheduled)
/// changes over time. A manual fetch performed during this feature's Coder
/// phase (2026-10-01, see the coder plan's "Live feed verification"
/// section) confirmed the feed is reachable, returns `text/calendar`, and
/// every current `VEVENT` is `RRULE`-based with `TZID=Australia/Sydney`
/// times — this test exercises the same path automatically going forward.
void main() {
  group('live events feed', () {
    test('the real feed can be fetched and parsed into valid, future-dated '
        'events', () async {
      final client = http.Client();
      addTearDown(client.close);
      final repository = FeedEventsRepository(
        ParishEventsFeedDatasource(client),
      );

      final events = await repository.getUpcomingEvents();

      // The parish's regular Mass schedule is recurring (confirmed
      // RRULE-based), so the feed should always expand to at least one
      // upcoming occurrence within the parser's lookahead window — if
      // this ever legitimately becomes 0, the inline section's
      // fully-empty state covers it (REQ-F08-016).
      expect(events, isNotEmpty);

      // REQ-F08-005: only current/future events are returned. `start`
      // is in the parser's "fake UTC" representation (see
      // ics_event_parser.dart), so the lower bound must be computed the
      // same way rather than compared against a real UTC instant. A
      // 1-hour buffer absorbs the gap between this call and the
      // repository's own internal "now" read, plus any single
      // in-progress event (started just before "now") the parser's own
      // start-based filter may still include.
      final sydneyNow = sydneyNowAsFakeUtc();
      for (final event in events) {
        expect(event.title, isNotEmpty);
        expect(event.uid, isNotEmpty);
        expect(event.displayTime, isNotEmpty);
        expect(
          event.start.isAfter(sydneyNow.subtract(const Duration(hours: 1))),
          isTrue,
          reason: 'Events feed should only return current/future events',
        );
      }

      // REQ-F08-005: explicit ascending sort by start.
      for (var i = 1; i < events.length; i++) {
        expect(
          events[i].start.isAfter(events[i - 1].start) ||
              events[i].start.isAtSameMomentAs(events[i - 1].start),
          isTrue,
          reason: 'Events should be sorted ascending by start',
        );
      }
    });

    test('the raw feed body is real iCalendar content starting with '
        'BEGIN:VCALENDAR', () async {
      final client = http.Client();
      addTearDown(client.close);
      final datasource = ParishEventsFeedDatasource(client);

      final ics = await datasource.fetchFeedIcs();

      expect(ics, contains('BEGIN:VCALENDAR'));
      expect(ics, contains('BEGIN:VEVENT'));
    });
  });
}
