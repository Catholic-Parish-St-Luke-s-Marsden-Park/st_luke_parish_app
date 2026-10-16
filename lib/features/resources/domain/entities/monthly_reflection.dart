/// One month's "Daily Readings & Reflections" booklet, e.g. October 2026.
class MonthlyReflection {
  const MonthlyReflection({
    required this.label,
    required this.month,
    required this.url,
  });

  /// As listed on the source page, e.g. "October 2026".
  final String label;

  /// The first day of the month it covers.
  final DateTime month;
  final String url;
}
