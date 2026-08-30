import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/news/data/datasources/bulletins_feed_datasource.dart';
import 'package:st_luke_parish_app/features/news/data/parsers/rss_bulletin_parser.dart';
import 'package:st_luke_parish_app/features/news/data/repositories/feed_bulletins_repository.dart';

/// Live integration test against the real parish site
/// (`https://stlukesmarsdenpark.org.au/category/bulletins/feed/`), per
/// CLAUDE.md's scraping test rules ("Live integration tests ... are
/// allowed and expected for scraping verification. Do not rely only on
/// mocked HTML") and REQ-F05-038(c).
///
/// Requires network access — if this fails in an offline/sandboxed CI
/// environment, that is an environment limitation, not necessarily a code
/// defect; the fixture-based unit tests in `rss_bulletin_parser_test.dart`
/// and `feed_bulletins_repository_test.dart` provide network-independent
/// coverage of the parsing/validation/sort logic itself.
///
/// Assertions are intentionally resilient (list-level/shape checks) rather
/// than asserting exact bulletin titles/dates, since the live feed's real
/// content changes weekly.
void main() {
  group('live bulletins feed', () {
    test(
      'the real feed can be fetched and parsed into valid bulletins',
      () async {
        final client = http.Client();
        addTearDown(client.close);
        final repository = FeedBulletinsRepository(
          BulletinsFeedDatasource(client),
        );

        final bulletins = await repository.getBulletins();

        // The parish always publishes at least one bulletin; if this ever
        // legitimately becomes 0, the UI's empty-state fallback link covers
        // it (REQ-F05-018) — this assertion documents the expected steady
        // state rather than hard-requiring non-empty output forever.
        expect(bulletins, isNotEmpty);
        expect(bulletins.length, lessThanOrEqualTo(6));

        for (final bulletin in bulletins) {
          expect(bulletin.title, isNotEmpty);
          final uri = Uri.tryParse(bulletin.pdfUrl);
          expect(uri, isNotNull, reason: 'pdfUrl should be a valid URI');
          expect(uri!.hasScheme, isTrue);
          expect(uri.host, isNotEmpty);
        }

        // Explicit newest-first sort (REQ-F05-006): dated items must be in
        // non-increasing pubDate order.
        final dated = bulletins.where((b) => b.date != null).toList();
        for (var i = 1; i < dated.length; i++) {
          expect(
            dated[i - 1].date!.isAfter(dated[i].date!) ||
                dated[i - 1].date!.isAtSameMomentAs(dated[i].date!),
            isTrue,
            reason: 'Bulletins should be sorted newest-first',
          );
        }
      },
    );

    test('the raw feed XML parses into at least one item via the parser '
        'directly', () async {
      final client = http.Client();
      addTearDown(client.close);
      final datasource = BulletinsFeedDatasource(client);

      final xml = await datasource.fetchFeedXml();
      final items = parseBulletinsRss(xml);

      expect(items, isNotEmpty);
    });
  });
}
