/// A single static "Parish News" entry (REQ-F05-010, REQ-F05-023).
/// Immutable; content is defined in `data/config/`, not inline in widgets.
class Announcement {
  const Announcement({
    required this.badge,
    required this.title,
    required this.body,
    required this.date,
  });

  /// Plain-text category label, e.g. "Milestone" — no icon/emoji
  /// (REQ-F05-027).
  final String badge;

  final String title;
  final String body;

  /// Pre-formatted display date, e.g. "October 2025" or "Ongoing".
  final String date;
}
