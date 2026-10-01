import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/events/data/parsers/ics_event_parser.dart';

/// Unit tests with controlled `.ics` fixtures, covering REQ-F08-002..006
/// edge cases per REQ-F08-039(a): successful extraction, folded-line
/// unfolding, `RRULE` expansion, a malformed `VEVENT` being skipped without
/// failing the whole parse, and an unparseable `RRULE` falling back to the
/// template's own single occurrence.
void main() {
  // A fixed "now", in the same fake-UTC representation the parser itself
  // uses — Wednesday 1 October 2026, 09:00 Sydney time.
  final now = DateTime.utc(2026, 10, 1, 9, 0, 0);

  String feedWith(String eventsIcs) {
    return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//Test//EN
$eventsIcs
END:VCALENDAR
''';
  }

  group('single non-recurring VEVENT', () {
    test('parses title, uid, start, location, description, url', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:event-1@stlukesmarsdenpark.org.au
SUMMARY:Walking with Christ - Scripture Group
DESCRIPTION:A weekly scripture reading and discussion group.
LOCATION:Parish Office
DTSTART;TZID=Australia/Sydney:20261008T190000
DTEND;TZID=Australia/Sydney:20261008T203000
URL:https://stlukesmarsdenpark.org.au/events/scripture-group/
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, hasLength(1));
      final event = events.single;
      expect(event.uid, 'event-1@stlukesmarsdenpark.org.au');
      expect(event.title, 'Walking with Christ - Scripture Group');
      expect(
        event.description,
        'A weekly scripture reading and discussion group.',
      );
      expect(event.location, 'Parish Office');
      expect(event.start, DateTime.utc(2026, 10, 8, 19, 0, 0));
      expect(event.end, DateTime.utc(2026, 10, 8, 20, 30, 0));
      expect(
        event.url,
        'https://stlukesmarsdenpark.org.au/events/scripture-group/',
      );
      expect(event.isAllDay, isFalse);
    });

    test('a past event (before now) is excluded', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:past-1@stlukesmarsdenpark.org.au
SUMMARY:Last Week's Working Bee
DTSTART;TZID=Australia/Sydney:20260924T090000
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, isEmpty);
    });

    test(
      'a date-only (all-day) DTSTART is parsed as midnight, isAllDay true',
      () {
        final ics = feedWith('''
BEGIN:VEVENT
UID:allday-1@stlukesmarsdenpark.org.au
SUMMARY:Parish Feast Day
DTSTART;VALUE=DATE:20261018
END:VEVENT
''');

        final events = parseIcsEvents(ics, now: now);

        expect(events, hasLength(1));
        expect(events.single.start, DateTime.utc(2026, 10, 18));
        expect(events.single.isAllDay, isTrue);
      },
    );
  });

  group('malformed/missing fields', () {
    test('a VEVENT missing SUMMARY is skipped, not thrown', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:no-summary@stlukesmarsdenpark.org.au
DTSTART;TZID=Australia/Sydney:20261008T190000
END:VEVENT
''');

      final skipped = <String>[];
      final events = parseIcsEvents(ics, now: now, onSkippedBlock: skipped.add);

      expect(events, isEmpty);
      expect(skipped, hasLength(1));
    });

    test('a VEVENT missing DTSTART is skipped, not thrown', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:no-dtstart@stlukesmarsdenpark.org.au
SUMMARY:Mystery Event
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, isEmpty);
    });

    test(
      'one malformed VEVENT does not prevent a later valid one from parsing',
      () {
        final ics = feedWith('''
BEGIN:VEVENT
UID:broken@stlukesmarsdenpark.org.au
SUMMARY:Broken Event
END:VEVENT
BEGIN:VEVENT
UID:ok@stlukesmarsdenpark.org.au
SUMMARY:Sunday Mass
DTSTART;TZID=Australia/Sydney:20261004T080000
END:VEVENT
''');

        final events = parseIcsEvents(ics, now: now);

        expect(events, hasLength(1));
        expect(events.single.title, 'Sunday Mass');
      },
    );

    test('an unparseable RRULE falls back to the template'
        '\'s own single occurrence', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:bad-rrule@stlukesmarsdenpark.org.au
SUMMARY:Sunday Mass
DTSTART;TZID=Australia/Sydney:20261004T080000
RRULE:NOT-A-VALID-RRULE
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, hasLength(1));
      expect(events.single.start, DateTime.utc(2026, 10, 4, 8, 0, 0));
    });
  });

  group('line folding', () {
    test('a folded (continuation-line) DESCRIPTION is unfolded correctly', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:folded-1@stlukesmarsdenpark.org.au
SUMMARY:Sunday Mass
DTSTART;TZID=Australia/Sydney:20261004T080000
DESCRIPTION:This is a long description that has been folded across
  multiple lines per RFC 5545's line-folding rule.
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, hasLength(1));
      expect(
        events.single.description,
        "This is a long description that has been folded across multiple "
        "lines per RFC 5545's line-folding rule.",
      );
    });
  });

  group('RRULE expansion', () {
    test('a weekly RRULE expands into multiple future occurrences', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:weekly-mass@stlukesmarsdenpark.org.au
SUMMARY:Sunday Mass
DTSTART;TZID=Australia/Sydney:20260906T080000
RRULE:FREQ=WEEKLY;BYDAY=SU
END:VEVENT
''');

      // now = 2026-10-01 09:00; a 21-day lookahead reaches 2026-10-22, so
      // the Sundays on 10-04, 10-11, and 10-18 should all appear (3
      // occurrences), each at 08:00, each a week apart.
      final events = parseIcsEvents(ics, now: now, lookaheadDays: 21);

      expect(events, hasLength(3));
      expect(events[0].start, DateTime.utc(2026, 10, 4, 8, 0, 0));
      expect(events[1].start, DateTime.utc(2026, 10, 11, 8, 0, 0));
      expect(events[2].start, DateTime.utc(2026, 10, 18, 8, 0, 0));
    });

    test('results are deduplicated by uid+start', () {
      final ics = feedWith('''
BEGIN:VEVENT
UID:dup@stlukesmarsdenpark.org.au
SUMMARY:Weekday Mass
DTSTART;TZID=Australia/Sydney:20261007T073000
END:VEVENT
BEGIN:VEVENT
UID:dup@stlukesmarsdenpark.org.au
SUMMARY:Weekday Mass
DTSTART;TZID=Australia/Sydney:20261007T073000
END:VEVENT
''');

      final events = parseIcsEvents(ics, now: now);

      expect(events, hasLength(1));
    });
  });
}
