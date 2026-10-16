/// Selector for the monthly booklet links on the Risen Lord Community's
/// "On Our Knees" page (ADR-0009). Each booklet is an `<a>` whose whole
/// text is its month, e.g. "October 2026".
/// See `.claude/context/selector-registry.md`.
abstract final class ReflectionsSelectors {
  /// Stable app-level name.
  static const key = 'daily_reflections_url';

  /// CSS selector for the candidate links.
  static const linkSelector = 'a[href]';

  static const monthNames = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];

  /// A link label that is just a month and year, e.g. "October 2026".
  static final monthLabel = RegExp(
    '^(${monthNames.join('|')})\\s+(\\d{4})\$',
    caseSensitive: false,
  );
}
