/// A single upcoming parish event, parsed from the live AI1EC calendar feed
/// (REQ-F08-008). Immutable; produced only by `FeedEventsRepository`, never
/// constructed ad hoc in presentation code.
///
/// For a recurring series (a weekly Mass, a regular group), one
/// [ParishEvent] is produced per expanded occurrence (REQ-F08-006) — each
/// occurrence carries the series' shared [uid], so [start] is what
/// distinguishes one occurrence from another, not [uid] alone.
class ParishEvent {
  const ParishEvent({
    required this.uid,
    required this.title,
    required this.start,
    required this.displayTime,
    this.end,
    this.location,
    this.description,
    this.detailUrl,
    this.isAllDay = false,
  });

  /// The feed's `UID` for this event's series. Recurring occurrences of the
  /// same series share a [uid]; combine with [start] for a stable per-row
  /// widget key.
  final String uid;

  /// The event's `SUMMARY`, e.g. "Sunday Mass" or "Walking with Christ —
  /// Scripture Group".
  final String title;

  /// Parsed `DTSTART`, normalized to the "fake UTC" representation described
  /// in `ics_event_parser.dart` — the UTC-labelled [DateTime] fields hold
  /// the intended `Australia/Sydney` wall-clock numbers, not a real UTC
  /// instant.
  final DateTime start;

  /// Parsed `DTEND`, in the same "fake UTC" representation as [start], or
  /// `null` if the feed omitted it.
  final DateTime? end;

  /// Pre-formatted Sydney-local date/time pill text, e.g. "Fri 2 Oct 6:30
  /// pm" or, for an all-day event, "Fri 2 Oct" — computed once in the
  /// repository (same precedent as `Bulletin.displayDate`) rather than
  /// re-derived in every row widget.
  final String displayTime;

  /// Whether this occurrence is an all-day (date-only `DTSTART`) event —
  /// [displayTime] already reflects this, but callers needing to branch on
  /// it directly (e.g. to skip a redundant time-of-day label) can use this.
  final bool isAllDay;

  /// The event's `LOCATION`, or `null` if the feed didn't provide one — the
  /// row only renders a location line when this is non-null/non-empty
  /// (matching the reference screenshot's "only present on events that have
  /// one" treatment).
  final String? location;

  /// The event's `DESCRIPTION`, shown in the in-app "Details" sheet
  /// (REQ-F08-023). May be `null`/empty.
  final String? description;

  /// The feed's per-event `URL`, when present — kept only as an optional
  /// secondary "View on parish website" link inside the "Details" sheet, not
  /// the primary action (REQ-F08-023). `null` when the feed didn't provide
  /// one; the sheet simply omits that secondary link in that case.
  final String? detailUrl;
}
