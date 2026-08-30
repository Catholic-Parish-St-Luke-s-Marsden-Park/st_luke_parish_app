/// A single bulletin, extracted from the parish's WordPress bulletins-category
/// RSS feed (REQ-F05-010). Immutable; produced only by
/// `FeedBulletinsRepository`, never constructed ad hoc in presentation code.
class Bulletin {
  const Bulletin({
    required this.title,
    required this.pageUrl,
    required this.pdfUrl,
    required this.date,
    required this.displayDate,
  });

  /// The bulletin post's title, e.g. "30th August 2026".
  final String title;

  /// The RSS item's `<link>` — the bulletin post's page on the parish site.
  final String pageUrl;

  /// The URL the "Download PDF ↗" affordance opens. This is the regex-
  /// extracted PDF link when one was found in `content:encoded`/`description`;
  /// otherwise it falls back to [pageUrl] (REQ-F05-004/REQ-F05-021), so the
  /// tap target is always valid and never silently dead.
  final String pdfUrl;

  /// Parsed `<pubDate>`, or `null` if the feed's date could not be parsed
  /// (REQ-F05-005) — undated items are still shown, just sorted last.
  final DateTime? date;

  /// Pre-formatted display date, e.g. "29 August 2026", or a placeholder
  /// string when [date] is `null`.
  final String displayDate;
}
