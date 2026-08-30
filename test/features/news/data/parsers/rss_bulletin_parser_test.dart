import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/news/data/parsers/rss_bulletin_parser.dart';
import 'package:st_luke_parish_app/features/news/domain/failures/bulletins_failure.dart';

/// Unit tests with controlled XML fixtures, covering REQ-F05-002..005 edge
/// cases per REQ-F05-038(a): successful extraction, `content:encoded`
/// present, `content:encoded` empty/`description` fallback,
/// no-PDF-match/`<link>` fallback, and unparseable `pubDate`.
void main() {
  String feedWith(String itemsXml) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
<title>Bulletins</title>
$itemsXml
</channel>
</rss>
''';
  }

  group('successful extraction from content:encoded', () {
    test('extracts title, PDF link, and pubDate', () {
      final xml = feedWith('''
<item>
  <title>30th August 2026</title>
  <link>https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/08/Bulletin-30-August-2026.pdf#new_tab</link>
  <pubDate>Sat, 29 Aug 2026 03:53:09 +0000</pubDate>
  <description><![CDATA[Bulletin 30 August 2026]]></description>
  <content:encoded><![CDATA[<p><a href="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/08/Bulletin-30-August-2026.pdf">Bulletin 30 August 2026</a></p>]]></content:encoded>
</item>
''');

      final items = parseBulletinsRss(xml);

      expect(items, hasLength(1));
      expect(items.first.title, '30th August 2026');
      expect(
        items.first.pdfUrl,
        'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/08/Bulletin-30-August-2026.pdf',
      );
      expect(items.first.pubDate, DateTime.utc(2026, 8, 29, 3, 53, 9));
    });
  });

  group('content:encoded empty — falls back to description', () {
    test(
      'extracts PDF link from description when content:encoded is empty',
      () {
        final xml = feedWith('''
<item>
  <title>Fallback Bulletin</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/fallback</link>
  <pubDate>Sat, 22 Aug 2026 02:07:27 +0000</pubDate>
  <description><![CDATA[<a href="https://stlukesmarsdenpark.org.au/files/fallback.pdf">Download</a>]]></description>
  <content:encoded><![CDATA[]]></content:encoded>
</item>
''');

        final items = parseBulletinsRss(xml);

        expect(
          items.first.pdfUrl,
          'https://stlukesmarsdenpark.org.au/files/fallback.pdf',
        );
      },
    );

    test(
      'extracts PDF link from description when content:encoded is absent',
      () {
        final xml = feedWith('''
<item>
  <title>No Content Encoded</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/none</link>
  <pubDate>Sat, 22 Aug 2026 02:07:27 +0000</pubDate>
  <description><![CDATA[<a href="https://stlukesmarsdenpark.org.au/files/none.pdf">Download</a>]]></description>
</item>
''');

        final items = parseBulletinsRss(xml);

        expect(
          items.first.pdfUrl,
          'https://stlukesmarsdenpark.org.au/files/none.pdf',
        );
      },
    );
  });

  group('no PDF match — falls back to <link>', () {
    test('uses the item link when neither field has a PDF href', () {
      final xml = feedWith('''
<item>
  <title>No PDF Here</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/no-pdf</link>
  <pubDate>Sat, 22 Aug 2026 02:07:27 +0000</pubDate>
  <description><![CDATA[Just some text, no link at all.]]></description>
  <content:encoded><![CDATA[<p>Nothing to see here.</p>]]></content:encoded>
</item>
''');

      final items = parseBulletinsRss(xml);

      expect(
        items.first.pdfUrl,
        'https://stlukesmarsdenpark.org.au/bulletins/no-pdf',
      );
    });
  });

  group('unparseable pubDate', () {
    test('does not throw; pubDate is null', () {
      final xml = feedWith('''
<item>
  <title>Bad Date</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/bad-date</link>
  <pubDate>not-a-real-date</pubDate>
  <content:encoded><![CDATA[<a href="https://stlukesmarsdenpark.org.au/files/bad-date.pdf">Download</a>]]></content:encoded>
</item>
''');

      final items = parseBulletinsRss(xml);

      expect(items.first.pubDate, isNull);
      expect(items.first.pdfUrl, isNotEmpty);
    });

    test('missing pubDate element does not throw; pubDate is null', () {
      final xml = feedWith('''
<item>
  <title>No Date At All</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/no-date</link>
  <content:encoded><![CDATA[<a href="https://stlukesmarsdenpark.org.au/files/no-date.pdf">Download</a>]]></content:encoded>
</item>
''');

      final items = parseBulletinsRss(xml);

      expect(items.first.pubDate, isNull);
    });
  });

  group('item cap', () {
    test('caps results at 6 items even when the feed has more', () {
      final items = List.generate(
        10,
        (i) =>
            '''
<item>
  <title>Bulletin $i</title>
  <link>https://stlukesmarsdenpark.org.au/bulletins/$i</link>
  <pubDate>Sat, 22 Aug 2026 02:07:27 +0000</pubDate>
  <content:encoded><![CDATA[<a href="https://stlukesmarsdenpark.org.au/files/$i.pdf">Download</a>]]></content:encoded>
</item>
''',
      ).join('\n');

      final parsed = parseBulletinsRss(feedWith(items));

      expect(parsed, hasLength(6));
    });
  });

  group('malformed XML', () {
    test('throws BulletinsParsingFailure', () {
      expect(
        () => parseBulletinsRss('<rss><channel><item><title>Unclosed'),
        throwsA(isA<BulletinsParsingFailure>()),
      );
    });
  });
}
