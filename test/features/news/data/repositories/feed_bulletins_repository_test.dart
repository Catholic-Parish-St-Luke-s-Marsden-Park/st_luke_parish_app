import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/news/data/datasources/bulletins_feed_datasource.dart';
import 'package:st_luke_parish_app/features/news/data/repositories/feed_bulletins_repository.dart';
import 'package:st_luke_parish_app/features/news/domain/failures/bulletins_failure.dart';

/// Covers REQ-F05-006 (explicit descending pubDate sort, independent of
/// feed order), REQ-F05-008 (URL validation before exposure to the domain
/// layer), and REQ-F05-012/013 (typed network/parsing failure conversion).
///
/// [FeedBulletinsRepository] takes a [BulletinsFeedDatasource], so these
/// tests exercise the real parser against controlled XML fixtures returned
/// by a fake datasource, rather than mocking the parser itself.
class _FakeDatasource implements BulletinsFeedDatasource {
  _FakeDatasource.returningXml(this._xml) : _error = null;
  _FakeDatasource.throwing(Object error) : _xml = null, _error = error;

  final String? _xml;
  final Object? _error;

  @override
  Future<String> fetchFeedXml() async {
    if (_error != null) throw _error;
    return _xml!;
  }
}

String _itemXml({
  required String title,
  required String link,
  required String pubDate,
  String? pdfHref,
}) {
  final content = pdfHref != null
      ? '<content:encoded><![CDATA[<a href="$pdfHref">Download</a>]]></content:encoded>'
      : '<content:encoded><![CDATA[]]></content:encoded>';
  return '''
<item>
  <title>$title</title>
  <link>$link</link>
  <pubDate>$pubDate</pubDate>
  $content
</item>
''';
}

String _feed(List<String> items) =>
    '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<title>Bulletins</title>
${items.join('\n')}
</channel>
</rss>
''';

void main() {
  group('REQ-F05-006: explicit descending sort by pubDate', () {
    test('sorts newest-first regardless of feed item order', () async {
      final xml = _feed([
        _itemXml(
          title: 'Older, listed first in feed',
          link: 'https://stlukesmarsdenpark.org.au/a',
          pubDate: 'Sat, 01 Aug 2026 00:00:00 +0000',
          pdfHref: 'https://stlukesmarsdenpark.org.au/a.pdf',
        ),
        _itemXml(
          title: 'Newest, listed second in feed',
          link: 'https://stlukesmarsdenpark.org.au/b',
          pubDate: 'Sat, 29 Aug 2026 00:00:00 +0000',
          pdfHref: 'https://stlukesmarsdenpark.org.au/b.pdf',
        ),
      ]);
      final repo = FeedBulletinsRepository(_FakeDatasource.returningXml(xml));

      final bulletins = await repo.getBulletins();

      expect(bulletins.map((b) => b.title), [
        'Newest, listed second in feed',
        'Older, listed first in feed',
      ]);
    });

    test('undated items (unparseable pubDate) sort last', () async {
      final xml = _feed([
        _itemXml(
          title: 'Undated',
          link: 'https://stlukesmarsdenpark.org.au/undated',
          pubDate: 'not-a-date',
          pdfHref: 'https://stlukesmarsdenpark.org.au/undated.pdf',
        ),
        _itemXml(
          title: 'Dated',
          link: 'https://stlukesmarsdenpark.org.au/dated',
          pubDate: 'Sat, 01 Aug 2026 00:00:00 +0000',
          pdfHref: 'https://stlukesmarsdenpark.org.au/dated.pdf',
        ),
      ]);
      final repo = FeedBulletinsRepository(_FakeDatasource.returningXml(xml));

      final bulletins = await repo.getBulletins();

      expect(bulletins.map((b) => b.title), ['Dated', 'Undated']);
      expect(bulletins.last.displayDate, 'Date unavailable');
    });
  });

  group('REQ-F05-008: URL validation before exposure', () {
    test('excludes an item whose resolved link fails URL validation', () async {
      final xml = _feed([
        _itemXml(
          title: 'Valid',
          link: 'https://stlukesmarsdenpark.org.au/valid',
          pubDate: 'Sat, 01 Aug 2026 00:00:00 +0000',
          pdfHref: 'https://stlukesmarsdenpark.org.au/valid.pdf',
        ),
        _itemXml(
          title: 'Invalid link',
          link: 'not a url at all',
          pubDate: 'Sat, 02 Aug 2026 00:00:00 +0000',
        ),
      ]);
      final repo = FeedBulletinsRepository(_FakeDatasource.returningXml(xml));

      final bulletins = await repo.getBulletins();

      expect(bulletins, hasLength(1));
      expect(bulletins.single.title, 'Valid');
    });
  });

  group('REQ-F05-012: network failures are converted, not raw exceptions', () {
    test(
      'a BulletinsNetworkFailure from the datasource propagates as-is',
      () async {
        final repo = FeedBulletinsRepository(
          _FakeDatasource.throwing(const BulletinsNetworkFailure('timed out')),
        );

        await expectLater(
          repo.getBulletins(),
          throwsA(isA<BulletinsNetworkFailure>()),
        );
      },
    );

    test('an unexpected datasource exception is converted to a typed '
        'failure, not left as a raw exception', () async {
      final repo = FeedBulletinsRepository(
        _FakeDatasource.throwing(Exception('boom')),
      );

      await expectLater(
        repo.getBulletins(),
        throwsA(isA<BulletinsParsingFailure>()),
      );
    });
  });

  group('REQ-F05-013: malformed feed XML is a typed parsing failure', () {
    test('throws BulletinsParsingFailure for malformed XML', () async {
      final repo = FeedBulletinsRepository(
        _FakeDatasource.returningXml('<rss><channel><item><title>Unclosed'),
      );

      await expectLater(
        repo.getBulletins(),
        throwsA(isA<BulletinsParsingFailure>()),
      );
    });
  });

  group('empty feed', () {
    test('returns an empty list rather than throwing', () async {
      final repo = FeedBulletinsRepository(
        _FakeDatasource.returningXml(_feed([])),
      );

      final bulletins = await repo.getBulletins();

      expect(bulletins, isEmpty);
    });
  });
}
