import '../../domain/entities/parish_event.dart';
import '../../domain/failures/events_failure.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/parish_events_feed_datasource.dart';
import '../parsers/ics_event_parser.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The sole implementation of [EventsRepository]: orchestrates fetch
/// (`ParishEventsFeedDatasource`) -> parse + expand recurring occurrences
/// (`parseIcsEvents`) -> URL validation -> explicit ascending sort -> mapping
/// to the typed [ParishEvent] domain entity (REQ-F08-009). Converts every
/// failure mode into an [EventsFailure] subtype rather than letting a raw
/// exception escape to the provider/UI (REQ-F08-010, REQ-F08-011).
class FeedEventsRepository implements EventsRepository {
  FeedEventsRepository(this._datasource);

  final ParishEventsFeedDatasource _datasource;

  @override
  Future<List<ParishEvent>> getUpcomingEvents() async {
    final String icsBody;
    try {
      icsBody = await _datasource.fetchFeedIcs();
    } on EventsFailure {
      rethrow;
    }

    try {
      final now = sydneyNowAsFakeUtc();
      final occurrences = parseIcsEvents(icsBody, now: now);

      if (occurrences.isEmpty && icsBody.trim().isEmpty) {
        // An empty response body (not just zero upcoming events in an
        // otherwise-valid feed) is treated as a parsing failure, not a
        // legitimate empty result (REQ-F08-011).
        throw const EventsParsingFailure('Events feed returned an empty body');
      }

      // REQ-F08-005: explicit ascending sort by start, independent of the
      // order VEVENT blocks/expanded occurrences happened to be produced in.
      final sorted = occurrences.toList()
        ..sort((a, b) => a.start.compareTo(b.start));

      return [
        for (final occurrence in sorted)
          ParishEvent(
            uid: occurrence.uid,
            title: occurrence.title,
            start: occurrence.start,
            end: occurrence.end,
            displayTime: _formatDisplayTime(occurrence),
            location: _blankToNull(occurrence.location),
            description: _blankToNull(occurrence.description),
            // REQ-F08-023: an invalid/unparseable per-event URL is treated
            // the same as no URL at all, never passed through to the UI.
            detailUrl: _validUrlOrNull(occurrence.url),
            isAllDay: occurrence.isAllDay,
          ),
      ];
    } on EventsFailure {
      rethrow;
    } catch (e) {
      // Defensive fallback (CLAUDE.md: "do not swallow exceptions
      // silently") — any unexpected error during parsing/mapping is still
      // surfaced as a typed, user-safe failure rather than a raw exception.
      throw EventsParsingFailure(
        'Unexpected error parsing the events feed: $e',
      );
    }
  }

  String? _blankToNull(String? value) =>
      (value == null || value.isEmpty) ? null : value;

  String? _validUrlOrNull(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return url;
  }

  String _formatDisplayTime(IcsEventOccurrence occurrence) {
    final start = occurrence.start;
    final weekday = _weekdayNames[start.weekday - 1];
    final month = _monthNames[start.month - 1];
    final datePart = '$weekday ${start.day} $month';
    if (occurrence.isAllDay) return datePart;

    var hour12 = start.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minute = start.minute.toString().padLeft(2, '0');
    final ampm = start.hour < 12 ? 'am' : 'pm';
    return '$datePart $hour12:$minute $ampm';
  }
}
