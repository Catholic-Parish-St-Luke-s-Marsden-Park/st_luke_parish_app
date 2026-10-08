import 'package:rrule/rrule.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// How far ahead recurring/one-off occurrences are expanded (REQ-F08-006).
/// One fetch+expand covers both the inline 7-day section and the All
/// Events screen's own pagination — the screen pages through this
/// already-expanded in-memory list, it does not re-fetch per page
/// (REQ-F08-029).
const int eventsLookaheadDays = 180;

/// A single expanded occurrence, parsed from one `VEVENT` block (one block
/// produces one occurrence if it has no `RRULE`, or many if it does —
/// REQ-F08-006). Not exposed outside `data/`; `FeedEventsRepository` maps
/// this into the domain `ParishEvent` entity.
///
/// [start]/[end] are in the "fake UTC" representation: the `DateTime`'s
/// UTC-labelled fields hold the *intended* `Australia/Sydney` wall-clock
/// numbers, not a real UTC instant (see [sydneyNowAsFakeUtc] below for why).
/// This matches the technique already proven in production by this same
/// parish's other app (`stlukes-marsden-park-app`'s
/// `netlify/functions/events.mjs`) — stepping an `RRULE` through plain UTC
/// arithmetic on these digits reproduces the same wall-clock time every
/// occurrence regardless of AEST/AEDT transitions, which is what a
/// recurring "5:30pm every Saturday" Mass actually means.
class IcsEventOccurrence {
  const IcsEventOccurrence({
    required this.uid,
    required this.title,
    required this.start,
    this.end,
    this.location,
    this.description,
    this.url,
    this.isAllDay = false,
  });

  final String uid;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final String? description;
  final String? url;
  final bool isAllDay;
}

bool _tzInitialized = false;

/// Returns the current `Australia/Sydney` wall-clock time, in the same
/// "fake UTC" representation [IcsEventOccurrence.start] uses. This is the
/// one place real IANA-timezone awareness (via `package:timezone`, already
/// a transitive dependency of `flutter_local_notifications`, added here as
/// a direct one) is needed — a fixed UTC+10/+11 offset would be wrong for
/// roughly half the year across the AEST/AEDT transition.
DateTime sydneyNowAsFakeUtc() {
  if (!_tzInitialized) {
    tz_data.initializeTimeZones();
    _tzInitialized = true;
  }
  final sydney = tz.getLocation('Australia/Sydney');
  final nowSydney = tz.TZDateTime.now(sydney);
  return DateTime.utc(
    nowSydney.year,
    nowSydney.month,
    nowSydney.day,
    nowSydney.hour,
    nowSydney.minute,
    nowSydney.second,
  );
}

/// Converts a "fake UTC" [DateTime] (see [IcsEventOccurrence]'s class doc
/// above -- a `DateTime` tagged UTC whose digits are actually the intended
/// `Australia/Sydney` wall-clock numbers, not a real UTC instant) into the
/// true UTC instant it represents.
///
/// This app reads a fake-UTC value's wall-clock digits directly everywhere
/// it displays a date/time (the date/time pill, the Details sheet, the
/// pre-formatted `displayTime` string) and never converts it via
/// `millisecondsSinceEpoch`, so the "fake" representation is invisible
/// there. It stops being invisible the moment a fake-UTC value crosses an
/// API boundary that *does* treat `DateTime` as a real instant -- which is
/// exactly what `add_2_calendar` does when exporting to the device calendar
/// (REQ-F08-024): it calls `.millisecondsSinceEpoch` on whatever `DateTime`
/// it's given, with no timezone handling of its own. Passing a fake-UTC
/// value there silently mis-converts by Sydney's own UTC offset (10 or 11
/// hours, AEST/AEDT) -- confirmed live (2026-10-08): a 7:00pm Sydney event
/// was added to the native calendar as 6:00am the *next* day, exactly an
/// 11-hour (AEDT) error. Call this to get the correct real-UTC instant
/// before handing a fake-UTC value to any such boundary.
DateTime sydneyFakeUtcToRealUtc(DateTime fakeUtc) {
  if (!_tzInitialized) {
    tz_data.initializeTimeZones();
    _tzInitialized = true;
  }
  final sydney = tz.getLocation('Australia/Sydney');
  final sydneyLocal = tz.TZDateTime(
    sydney,
    fakeUtc.year,
    fakeUtc.month,
    fakeUtc.day,
    fakeUtc.hour,
    fakeUtc.minute,
    fakeUtc.second,
  );
  return sydneyLocal.toUtc();
}

String _unfoldIcs(String text) {
  return text
      .replaceAll(RegExp(r'\r\n[ \t]'), '')
      .replaceAll(RegExp(r'\n[ \t]'), '');
}

String _unescapeIcsText(String? raw) {
  if (raw == null) return '';
  return raw
      .replaceAll(RegExp(r'\\[nN]'), ' ')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', r'\')
      .trim();
}

({String params, String value})? _extractField(String block, String name) {
  final re = RegExp('^$name(;[^:\\n]*)?:(.*)\$', multiLine: true);
  final match = re.firstMatch(block);
  if (match == null) return null;
  return (params: match.group(1) ?? '', value: (match.group(2) ?? '').trim());
}

({DateTime value, bool isAllDay})? _parseIcsDateTime(
  String params,
  String rawValue,
) {
  // Full date-time: yyyymmddThhmmss, optionally Z-suffixed. Both a
  // TZID=Australia/Sydney floating-local value and a Z-suffixed one are
  // treated identically here (REQ-F08-003) — see the class doc above.
  final dtMatch = RegExp(
    r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z)?$',
  ).firstMatch(rawValue);
  if (dtMatch != null) {
    final y = int.parse(dtMatch.group(1)!);
    final mo = int.parse(dtMatch.group(2)!);
    final d = int.parse(dtMatch.group(3)!);
    final h = int.parse(dtMatch.group(4)!);
    final mi = int.parse(dtMatch.group(5)!);
    final s = int.parse(dtMatch.group(6)!);
    return (value: DateTime.utc(y, mo, d, h, mi, s), isAllDay: false);
  }

  // Date-only (all-day event): yyyymmdd.
  final dateMatch = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(rawValue);
  if (dateMatch != null) {
    final y = int.parse(dateMatch.group(1)!);
    final mo = int.parse(dateMatch.group(2)!);
    final d = int.parse(dateMatch.group(3)!);
    return (value: DateTime.utc(y, mo, d), isAllDay: true);
  }

  return null;
}

/// Parses the raw iCalendar feed body into expanded occurrences
/// (REQ-F08-002, REQ-F08-006), bounded to `[now, now + lookaheadDays]`. A
/// malformed/unparseable `VEVENT` block is skipped individually — logged
/// via [onSkippedBlock], never thrown — rather than failing the whole feed
/// (REQ-F08-004).
List<IcsEventOccurrence> parseIcsEvents(
  String icsText, {
  required DateTime now,
  int lookaheadDays = eventsLookaheadDays,
  void Function(String reason)? onSkippedBlock,
}) {
  final text = _unfoldIcs(icsText);
  final blocks = RegExp(
    r'BEGIN:VEVENT([\s\S]*?)END:VEVENT',
  ).allMatches(text).map((m) => m.group(1) ?? '');
  final horizon = now.add(Duration(days: lookaheadDays));

  final occurrences = <IcsEventOccurrence>[];
  final seen = <String>{};

  for (final block in blocks) {
    try {
      final summaryField = _extractField(block, 'SUMMARY');
      final dtstartField = _extractField(block, 'DTSTART');
      if (summaryField == null || dtstartField == null) {
        onSkippedBlock?.call('missing SUMMARY or DTSTART');
        continue;
      }

      final title = _unescapeIcsText(summaryField.value);
      final parsedStart = _parseIcsDateTime(
        dtstartField.params,
        dtstartField.value,
      );
      if (parsedStart == null) {
        onSkippedBlock?.call('unparseable DTSTART "${dtstartField.value}"');
        continue;
      }

      Duration? duration;
      final dtendField = _extractField(block, 'DTEND');
      if (dtendField != null) {
        final parsedEnd = _parseIcsDateTime(
          dtendField.params,
          dtendField.value,
        );
        if (parsedEnd != null) {
          duration = parsedEnd.value.difference(parsedStart.value);
        }
      }

      final rruleField = _extractField(block, 'RRULE');
      final urlField = _extractField(block, 'URL');
      final locationField = _extractField(block, 'LOCATION');
      final descriptionField = _extractField(block, 'DESCRIPTION');
      final uidField = _extractField(block, 'UID');

      final uid = uidField != null ? _unescapeIcsText(uidField.value) : title;
      final location = locationField != null
          ? _unescapeIcsText(locationField.value)
          : null;
      final description = descriptionField != null
          ? _unescapeIcsText(descriptionField.value)
          : null;
      final url = urlField != null && urlField.value.isNotEmpty
          ? urlField.value.trim()
          : null;

      final starts = <DateTime>[];
      if (rruleField != null) {
        try {
          // RecurrenceRule.fromString expects the full property line
          // including the "RRULE:" prefix, not just the value portion
          // after the colon (confirmed against the package's own
          // published usage example) — rruleField.value is only the
          // value, so it's re-prefixed here.
          final rule = RecurrenceRule.fromString('RRULE:${rruleField.value}');
          starts.addAll(
            rule.getInstances(
              start: parsedStart.value,
              after: now,
              before: horizon,
            ),
          );
        } catch (e) {
          onSkippedBlock?.call('unparseable RRULE "${rruleField.value}": $e');
          // Fall back to the template's own DTSTART as a single occurrence
          // if it's itself within the window, rather than dropping the
          // whole event (REQ-F08-004).
          if (!parsedStart.value.isBefore(now) &&
              parsedStart.value.isBefore(horizon)) {
            starts.add(parsedStart.value);
          }
        }
      } else if (!parsedStart.value.isBefore(now) &&
          parsedStart.value.isBefore(horizon)) {
        starts.add(parsedStart.value);
      }

      for (final start in starts) {
        final dedupeKey = '$uid|${start.toIso8601String()}';
        if (!seen.add(dedupeKey)) continue;
        occurrences.add(
          IcsEventOccurrence(
            uid: uid,
            title: title,
            start: start,
            end: duration != null ? start.add(duration) : null,
            location: location,
            description: description,
            url: url,
            isAllDay: parsedStart.isAllDay,
          ),
        );
      }
    } catch (e) {
      // Defensive fallback (CLAUDE.md: "do not swallow exceptions
      // silently", but still scoped to this one block): any unexpected
      // error skips just this `VEVENT`, never the whole feed.
      onSkippedBlock?.call('unexpected error parsing VEVENT block: $e');
      continue;
    }
  }

  return occurrences;
}
