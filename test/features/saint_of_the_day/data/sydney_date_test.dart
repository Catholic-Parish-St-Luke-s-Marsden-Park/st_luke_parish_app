import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/sydney_date.dart';

/// Covers the hand-rolled Australia/Sydney DST rule (see ADR-0005) used for
/// REQ-F06-008's cache date key. Each case uses a UTC time comfortably
/// within a calendar day at either offset (+10/+11) so a same-day
/// conversion is unambiguous, per the ADR's documented boundary caveat.
void main() {
  group('sydneyNow — DST offset', () {
    test('mid-January (AEDT, UTC+11) applies an 11-hour offset', () {
      final utc = DateTime.utc(2026, 1, 15, 12);

      final sydney = sydneyNow(utc);

      expect(sydney, DateTime.utc(2026, 1, 15, 23));
    });

    test('mid-July (AEST, UTC+10) applies a 10-hour offset', () {
      final utc = DateTime.utc(2026, 7, 15, 12);

      final sydney = sydneyNow(utc);

      expect(sydney, DateTime.utc(2026, 7, 15, 22));
    });

    test('mid-November (AEDT, UTC+11) applies an 11-hour offset', () {
      final utc = DateTime.utc(2026, 11, 15, 12);

      final sydney = sydneyNow(utc);

      expect(sydney, DateTime.utc(2026, 11, 15, 23));
    });
  });

  group('sydneyDateKey', () {
    test('formats as zero-padded YYYY-MM-DD', () {
      expect(sydneyDateKey(DateTime.utc(2026, 1, 5)), '2026-01-05');
      expect(sydneyDateKey(DateTime.utc(2026, 12, 25)), '2026-12-25');
    });
  });

  group('sydneyDisplayDate', () {
    test('formats as "Month Day"', () {
      expect(sydneyDisplayDate(DateTime.utc(2026, 9, 1)), 'September 1');
    });
  });

  group('sydneyFullDateForPrompt', () {
    test('formats as "Weekday, Month Day, Year"', () {
      expect(
        sydneyFullDateForPrompt(DateTime.utc(2026, 1, 15)),
        'Thursday, January 15, 2026',
      );
    });
  });
}
