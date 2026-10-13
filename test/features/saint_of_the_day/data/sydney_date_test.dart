import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/sydney_date.dart';

/// Covers the hand-rolled Australia/Sydney DST rule that picks which day's
/// saint is requested (REQ-F09-019, RISK-F09-004).
void main() {
  String keyAt(DateTime utc) => sydneyDateKey(sydneyNow(utc));

  group('sydneyNow — DST offset', () {
    test('mid-January (AEDT, UTC+11) applies an 11-hour offset', () {
      expect(
        sydneyNow(DateTime.utc(2026, 1, 15, 12)),
        DateTime.utc(2026, 1, 15, 23),
      );
    });

    test('mid-July (AEST, UTC+10) applies a 10-hour offset', () {
      expect(
        sydneyNow(DateTime.utc(2026, 7, 15, 12)),
        DateTime.utc(2026, 7, 15, 22),
      );
    });

    test('mid-November (AEDT, UTC+11) applies an 11-hour offset', () {
      expect(
        sydneyNow(DateTime.utc(2026, 11, 15, 12)),
        DateTime.utc(2026, 11, 15, 23),
      );
    });

    test('a non-UTC input is converted to UTC first', () {
      final utc = DateTime.utc(2026, 7, 15, 12);
      expect(sydneyNow(utc.toLocal()), sydneyNow(utc));
    });
  });

  group('sydneyDateKey', () {
    test('formats as zero-padded YYYY-MM-DD', () {
      expect(sydneyDateKey(DateTime.utc(2026, 1, 5)), '2026-01-05');
      expect(sydneyDateKey(DateTime.utc(2026, 12, 25)), '2026-12-25');
    });
  });

  group('date around Sydney midnight', () {
    test('AEST (July): 13:59 UTC is still the 15th, 14:00 UTC the 16th', () {
      expect(keyAt(DateTime.utc(2026, 7, 15, 13, 59)), '2026-07-15');
      expect(keyAt(DateTime.utc(2026, 7, 15, 14)), '2026-07-16');
    });

    test('AEDT (January): 12:59 UTC is still the 15th, 13:00 UTC the 16th', () {
      expect(keyAt(DateTime.utc(2026, 1, 15, 12, 59)), '2026-01-15');
      expect(keyAt(DateTime.utc(2026, 1, 15, 13)), '2026-01-16');
    });

    test('New Year in Sydney comes while it is still Dec 31 in UTC', () {
      expect(keyAt(DateTime.utc(2026, 12, 31, 13)), '2027-01-01');
    });

    test('leap day 2028: Sydney midnight into and out of 29 February', () {
      expect(keyAt(DateTime.utc(2028, 2, 28, 12, 59)), '2028-02-28');
      expect(keyAt(DateTime.utc(2028, 2, 28, 13)), '2028-02-29');
      expect(keyAt(DateTime.utc(2028, 2, 29, 13)), '2028-03-01');
    });
  });

  group('DST changeover windows keep the right calendar date '
      '(RISK-F09-004)', () {
    // 2026: DST ends Sun 5 April (real switch 16:00 UTC Sat 4 April) and
    // starts Sun 4 October (real switch 16:00 UTC Sat 3 October). The rule
    // switches at 00:00 UTC on the Sunday instead, so between those two
    // instants the computed time is an hour out — but always on the Sunday.
    test('April: across the mis-modelled 16:00–00:00 UTC window', () {
      expect(keyAt(DateTime.utc(2026, 4, 4, 12, 59)), '2026-04-04');
      expect(keyAt(DateTime.utc(2026, 4, 4, 13)), '2026-04-05');
      expect(keyAt(DateTime.utc(2026, 4, 4, 16)), '2026-04-05');
      expect(keyAt(DateTime.utc(2026, 4, 4, 23, 59)), '2026-04-05');
      expect(keyAt(DateTime.utc(2026, 4, 5)), '2026-04-05');
      expect(keyAt(DateTime.utc(2026, 4, 5, 13, 59)), '2026-04-05');
      expect(keyAt(DateTime.utc(2026, 4, 5, 14)), '2026-04-06');
    });

    // Tester phase: years where the 1st of the month is itself the first
    // Sunday (zero-day offset in `_firstSundayOfMonthUtc`), so the real
    // switch falls on the last day of the previous month.
    test('October 2028 (1 Oct is a Sunday): real switch 16:00 UTC Sat '
        '30 Sep', () {
      expect(keyAt(DateTime.utc(2028, 9, 30, 13, 59)), '2028-09-30');
      expect(keyAt(DateTime.utc(2028, 9, 30, 14)), '2028-10-01');
      expect(keyAt(DateTime.utc(2028, 9, 30, 23, 59)), '2028-10-01');
      expect(keyAt(DateTime.utc(2028, 10, 1)), '2028-10-01');
      expect(keyAt(DateTime.utc(2028, 10, 1, 12, 59)), '2028-10-01');
      expect(keyAt(DateTime.utc(2028, 10, 1, 13)), '2028-10-02');
    });

    test('April 2029 (1 Apr is a Sunday): real switch 16:00 UTC Sat '
        '31 Mar', () {
      expect(keyAt(DateTime.utc(2029, 3, 31, 12, 59)), '2029-03-31');
      expect(keyAt(DateTime.utc(2029, 3, 31, 13)), '2029-04-01');
      expect(keyAt(DateTime.utc(2029, 3, 31, 23, 59)), '2029-04-01');
      expect(keyAt(DateTime.utc(2029, 4, 1)), '2029-04-01');
      expect(keyAt(DateTime.utc(2029, 4, 1, 13, 59)), '2029-04-01');
      expect(keyAt(DateTime.utc(2029, 4, 1, 14)), '2029-04-02');
    });

    test('October: across the mis-modelled 16:00–00:00 UTC window', () {
      expect(keyAt(DateTime.utc(2026, 10, 3, 13, 59)), '2026-10-03');
      expect(keyAt(DateTime.utc(2026, 10, 3, 14)), '2026-10-04');
      expect(keyAt(DateTime.utc(2026, 10, 3, 16)), '2026-10-04');
      expect(keyAt(DateTime.utc(2026, 10, 3, 23, 59)), '2026-10-04');
      expect(keyAt(DateTime.utc(2026, 10, 4)), '2026-10-04');
      expect(keyAt(DateTime.utc(2026, 10, 4, 12, 59)), '2026-10-04');
      expect(keyAt(DateTime.utc(2026, 10, 4, 13)), '2026-10-05');
    });
  });
}
