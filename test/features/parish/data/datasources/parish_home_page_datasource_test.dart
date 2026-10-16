import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/core/constants/external_links.dart';
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';

void main() {
  test('returns the body on HTTP 200, requesting the home page with the '
      "app's User-Agent", () async {
    Uri? url;
    String? userAgent;
    final datasource = ParishHomePageDatasource(
      MockClient((request) async {
        url = request.url;
        userAgent = request.headers['User-Agent'];
        return http.Response('<html></html>', 200);
      }),
    );

    expect(await datasource.fetchHomePageHtml(), '<html></html>');
    expect(url, Uri.parse(ExternalLinks.parishHomePage));
    expect(userAgent, startsWith('StLukesParishApp/'));
  });

  test('a non-200 status is a network failure', () {
    final datasource = ParishHomePageDatasource(
      MockClient((_) async => http.Response('blocked', 403)),
    );
    expect(
      datasource.fetchHomePageHtml(),
      throwsA(isA<ParishDocumentsNetworkFailure>()),
    );
  });

  test('a thrown client error is a network failure', () {
    final datasource = ParishHomePageDatasource(
      MockClient((_) async => throw http.ClientException('offline')),
    );
    expect(
      datasource.fetchHomePageHtml(),
      throwsA(isA<ParishDocumentsNetworkFailure>()),
    );
  });

  group('fetchImage', () {
    ParishHomePageDatasource withResponse(int status, String type) =>
        ParishHomePageDatasource(
          MockClient((request) async {
            expect(request.method, 'GET');
            return http.Response.bytes(
              [1, 2, 3],
              status,
              headers: {'content-type': type},
            );
          }),
        );

    test('returns the bytes of an image that loads', () async {
      expect(
        await withResponse(200, 'image/jpeg').fetchImage('https://x/a.jpg'),
        [1, 2, 3],
      );
    });

    test('null for a missing file or a page that is not an image', () async {
      expect(
        await withResponse(404, 'text/html').fetchImage('https://x/a.jpg'),
        isNull,
      );
      expect(
        await withResponse(200, 'text/html').fetchImage('https://x/a.jpg'),
        isNull,
      );
    });

    test('null when offline', () async {
      final datasource = ParishHomePageDatasource(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(await datasource.fetchImage('https://x/a.jpg'), isNull);
    });
  });
}
