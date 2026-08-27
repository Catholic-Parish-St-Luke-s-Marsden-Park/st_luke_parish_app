/// Typed constants for external URLs consumed by this app's WebView/launch
/// flows. Keeps external URLs out of inline string literals in screens and
/// widgets, per root `CLAUDE.md`'s "no magic strings" guidance.
abstract final class ExternalLinks {
  static const String parishSite = 'https://stlukesmarsdenpark.org.au';

  /// The parish website's Donate page, loaded in-app via
  /// `SimpleWebViewScreen` on the Donate tab.
  static const String donate = '$parishSite/donate/';
}
