/// The Parish Pastoral Plan 2026–2028, as published on the parish website
/// (parish request, 2026-10-16).
abstract final class PastoralPlanConfig {
  static const title = 'Our Parish Pastoral Plan 2026–2028';

  static const summary =
      'Our Parish Pastoral Plan rests on four strategic pillars: Faith '
      'Enrichment, Serving God and Others, Stronger Community Connection, '
      'and A Vibrant Worship Experience.';

  /// The four-pillars graphic from the parish home page, bundled locally.
  static const pillarsAsset = 'assets/images/parish/pastoral_pillars.png';

  static const pillarsImageLabel =
      'Our Evangelisation Mission, supported by four pillars: Faith '
      'Enrichment, Serving God and Others, Stronger Community Connection '
      'and Vibrant Worship Experience';

  static const pdfUrl =
      'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
      'Parish-Pastoral-Plan-2026-2028.pdf';

  /// Pastoral Council minutes known when this build was made. The app reads
  /// the current link from the parish home page; this one is used until
  /// that has loaded, or if it can't be read.
  static const councilMinutesUrl =
      'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
      '19-September-2026-Parish-Pastoral-Council-Meeting-Minutes.pdf';
}
