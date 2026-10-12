/// Computes the current calendar date in `Australia/Sydney` local time.
/// The repository uses it to pick which day's saint to request from
/// `GET /v1/saints/{date}` and which cache entry to read (D-3, REQ-F09-019).
///
/// The time is derived from UTC (`DateTime.now().toUtc()`), so the device's
/// own timezone setting does not matter — only absolute clock error does
/// (RISK-F09-002).
///
/// Applies the NSW daylight-saving rule directly: AEDT (UTC+11) from the
/// first Sunday of October to the first Sunday of April, AEST (UTC+10)
/// otherwise. The switch is made at 00:00 UTC on that Sunday, whereas the
/// real change happens at 16:00 UTC on the Saturday before, so for those
/// ~8 hours the computed Sydney time is an hour out. That window falls
/// between roughly 02:00 and 11:00 Sydney time on the Sunday, so the
/// calendar date — the only thing this file is used for — is unaffected
/// (RISK-F09-004). If the NSW DST rule ever changes in law, this needs
/// updating alongside it.
library;

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

/// `YYYY-MM-DD` key for [sydneyLocal]: both the requested date and the
/// cache key (REQ-F09-001, REQ-F09-011).
String sydneyDateKey(DateTime sydneyLocal) {
  final y = sydneyLocal.year.toString().padLeft(4, '0');
  final m = sydneyLocal.month.toString().padLeft(2, '0');
  final d = sydneyLocal.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
