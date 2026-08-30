/// Typed constants for external URLs consumed by this app's WebView/launch
/// flows. Keeps external URLs out of inline string literals in screens and
/// widgets, per root `CLAUDE.md`'s "no magic strings" guidance.
abstract final class ExternalLinks {
  static const String parishSite = 'https://stlukesmarsdenpark.org.au';

  /// The parish website's Donate page, loaded in-app via
  /// `SimpleWebViewScreen` on the Donate tab.
  static const String donate = '$parishSite/donate/';

  /// WordPress category RSS feed the News tab fetches bulletins from
  /// (REQ-F05-001). See `.claude/decisions/0004-news-rss-regex-vs-css-selector.md`
  /// for why this feature uses RSS+regex instead of CSS-selector scraping.
  static const String bulletinsFeed = '$parishSite/category/bulletins/feed/';

  /// The parish website's rendered bulletins archive page, opened externally
  /// as a fallback link when the live feed is empty or fails to load/parse
  /// (REQ-F05-018/019/020).
  static const String bulletinsArchive = '$parishSite/category/bulletins/';

  /// The parish website's prayer-request section, opened externally via the
  /// News tab's "Submit a Prayer Request" CTA (REQ-F05-028).
  static const String prayerRequests = '$parishSite/#prayerrequests';
}
