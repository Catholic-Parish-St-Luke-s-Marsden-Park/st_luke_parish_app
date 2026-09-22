/// Computes the current calendar date in `Australia/Sydney` local time,
/// without adding a `timezone`-database package (out of the approved BA
/// plan's scope, which lists only `shared_preferences` as a new
/// dependency — see ADR-0005).
///
/// Applies the NSW daylight-saving rule directly: AEDT (UTC+11) from the
/// first Sunday of October to the first Sunday of April, AEST (UTC+10)
/// otherwise. This is a deliberate simplification versus the reference
/// Netlify function's `Intl.DateTimeFormat(..., { timeZone: 'Australia/Sydney' })`,
/// which resolves the real IANA tz database — it can be off by up to an
/// hour only in the couple of hours immediately around the twice-yearly
/// clock change, which does not affect which calendar day a once-a-day
/// cache key resolves to in practice. If the Australian DST rule itself
/// ever changes, this needs updating alongside it.
library;

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

DateTime _firstSundayOfMonthUtc(int year, int month) {
  final first = DateTime.utc(year, month, 1);
  final daysUntilSunday = (DateTime.sunday - first.weekday) % 7;
  return first.add(Duration(days: daysUntilSunday));
}

bool _isSydneyDst(DateTime utc) {
  final octStart = _firstSundayOfMonthUtc(utc.year, 10);
  final aprEnd = _firstSundayOfMonthUtc(utc.year, 4);
  if (utc.isBefore(aprEnd)) return true;
  if (!utc.isBefore(octStart)) return true;
  return false;
}

/// Sydney-local wall-clock time for [utcNow] (defaults to `DateTime.now()`
/// converted to UTC).
DateTime sydneyNow([DateTime? utcNow]) {
  final utc = (utcNow ?? DateTime.now()).toUtc();
  return utc.add(Duration(hours: _isSydneyDst(utc) ? 11 : 10));
}

/// `YYYY-MM-DD` cache key for [sydneyLocal] (REQ-F06-008).
String sydneyDateKey(DateTime sydneyLocal) {
  final y = sydneyLocal.year.toString().padLeft(4, '0');
  final m = sydneyLocal.month.toString().padLeft(2, '0');
  final d = sydneyLocal.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Human-readable display date for the screen header, e.g. "September 1".
String sydneyDisplayDate(DateTime sydneyLocal) =>
    '${_monthNames[sydneyLocal.month - 1]} ${sydneyLocal.day}';

/// Full weekday/date string for the model prompt, e.g. "Tuesday, September
/// 1, 2026" — matches the reference Netlify function's `fullDate` prompt
/// input shape closely enough for the model to answer correctly; exact
/// weekday-name formatting is not required for a valid response.
String sydneyFullDateForPrompt(DateTime sydneyLocal) {
  const weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final weekday = weekdayNames[sydneyLocal.weekday - 1];
  final month = _monthNames[sydneyLocal.month - 1];
  return '$weekday, $month ${sydneyLocal.day}, ${sydneyLocal.year}';
}
