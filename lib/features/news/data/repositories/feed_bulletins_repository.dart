import '../../domain/entities/bulletin.dart';
import '../../domain/failures/bulletins_failure.dart';
import '../../domain/repositories/bulletins_repository.dart';
import '../datasources/bulletins_feed_datasource.dart';
import '../parsers/rss_bulletin_parser.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// The sole implementation of [BulletinsRepository]: orchestrates fetch
/// (`BulletinsFeedDatasource`) -> parse (`parseBulletinsRss`) -> URL
/// validation -> explicit newest-first sort -> mapping to the typed
/// [Bulletin] domain entity (REQ-F05-011). Converts every failure mode into
/// a [BulletinsFailure] subtype rather than letting a raw exception escape
/// to the provider/UI (REQ-F05-012, REQ-F05-013).
class FeedBulletinsRepository implements BulletinsRepository {
  FeedBulletinsRepository(this._datasource);

  final BulletinsFeedDatasource _datasource;

  @override
  Future<List<Bulletin>> getBulletins() async {
    try {
      final xmlBody = await _datasource.fetchFeedXml();
      final rawItems = parseBulletinsRss(xmlBody);

      // REQ-F05-008: drop any item whose resolved link fails URL
      // validation, rather than passing an unusable/dead link through to
      // the UI.
      final validItems = rawItems.where((raw) => _isValidUrl(raw.pdfUrl));

      // REQ-F05-006: explicit descending sort by parsed pubDate, independent
      // of feed order — undated items sort last rather than being dropped.
      final sorted = validItems.toList()
        ..sort((a, b) {
          final aDate = a.pubDate;
          final bDate = b.pubDate;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

      return [
        for (final raw in sorted)
          Bulletin(
            title: raw.title,
            pageUrl: raw.pageUrl,
            pdfUrl: raw.pdfUrl,
            date: raw.pubDate,
            displayDate: raw.pubDate != null
                ? _formatDate(raw.pubDate!)
                : 'Date unavailable',
          ),
      ];
    } on BulletinsFailure {
      rethrow;
    } catch (e) {
      // Defensive fallback (CLAUDE.md: "do not swallow exceptions
      // silently") — any unexpected error during parsing/mapping is still
      // surfaced as a typed, user-safe failure rather than a raw exception.
      throw BulletinsParsingFailure(
        'Unexpected error parsing the bulletins feed: $e',
      );
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}
