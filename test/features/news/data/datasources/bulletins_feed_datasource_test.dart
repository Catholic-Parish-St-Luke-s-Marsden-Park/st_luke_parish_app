import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/core/constants/external_links.dart';
import 'package:st_luke_parish_app/features/news/data/datasources/bulletins_feed_datasource.dart';
import 'package:st_luke_parish_app/features/news/domain/failures/bulletins_failure.dart';

/// Direct unit tests for [BulletinsFeedDatasource], isolated from the
/// repository/parser — the repository's own tests exercise a *fake*
/// datasource that already returns pre-made XML/failures, so they never
/// actually verify that this class converts a real `http.Client` response
/// (non-2xx status, thrown exception) into a [BulletinsNetworkFailure], nor
/// that it requests the correct URL/header. Added by Tester to close that
/// gap (REQ-F05-001, REQ-F05-012).
void main() {
  group('fetchFeedXml — success', () {
    test('returns the response body on HTTP 200', () async {
      final client = MockClient((request) async {
        return http.Response('<rss>ok</rss>', 200);
      });
      final datasource = BulletinsFeedDatasource(client);

      final body = await datasource.fetchFeedXml();

      expect(body, '<rss>ok</rss>');
    });

    test(
      'requests the bulletins feed URL with a descriptive User-Agent',
      () async {
        Uri? requestedUri;
        String? userAgent;
        final client = MockClient((request) async {
          requestedUri = request.url;
          userAgent = request.headers['User-Agent'];
          return http.Response('<rss></rss>', 200);
        });
        final datasource = BulletinsFeedDatasource(client);

        await datasource.fetchFeedXml();

        expect(requestedUri, Uri.parse(ExternalLinks.bulletinsFeed));
        // The feed host's WAF 403s requests with no/generic User-Agent
        // (see ADR-0004 and the coder plan) — this must never regress to an
        // empty/default header.
        expect(userAgent, isNotNull);
        expect(userAgent, isNotEmpty);
      },
    );
  });

  group('fetchFeedXml — non-2xx response', () {
    test('a 404 response is converted to BulletinsNetworkFailure', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final datasource = BulletinsFeedDatasource(client);

      await expectLater(
        datasource.fetchFeedXml(),
        throwsA(isA<BulletinsNetworkFailure>()),
      );
    });

    test('a 500 response is converted to BulletinsNetworkFailure', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });
      final datasource = BulletinsFeedDatasource(client);

      await expectLater(
        datasource.fetchFeedXml(),
        throwsA(isA<BulletinsNetworkFailure>()),
      );
    });

    test('a 403 response (e.g. WAF rejection) is converted to '
        'BulletinsNetworkFailure', () async {
      final client = MockClient((request) async {
        return http.Response('Forbidden', 403);
      });
      final datasource = BulletinsFeedDatasource(client);

      await expectLater(
        datasource.fetchFeedXml(),
        throwsA(isA<BulletinsNetworkFailure>()),
      );
    });
  });

  group('fetchFeedXml — client/network exceptions', () {
    test(
      'a thrown client exception is converted to BulletinsNetworkFailure',
      () async {
        final client = MockClient((request) async {
          throw http.ClientException('Connection refused');
        });
        final datasource = BulletinsFeedDatasource(client);

        await expectLater(
          datasource.fetchFeedXml(),
          throwsA(isA<BulletinsNetworkFailure>()),
        );
      },
    );

    test('no raw exception detail leaks into the failure type (message is '
        'still explicit/typed, not a bare rethrow)', () async {
      final client = MockClient((request) async {
        throw Exception('some low-level socket error');
      });
      final datasource = BulletinsFeedDatasource(client);

      try {
        await datasource.fetchFeedXml();
        fail('Expected BulletinsNetworkFailure to be thrown');
      } catch (e) {
        expect(e, isA<BulletinsNetworkFailure>());
      }
    });
  });
}
