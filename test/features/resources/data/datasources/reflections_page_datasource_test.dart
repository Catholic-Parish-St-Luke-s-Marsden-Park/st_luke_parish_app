import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/core/constants/external_links.dart';
import 'package:st_luke_parish_app/features/resources/data/datasources/reflections_page_datasource.dart';
import 'package:st_luke_parish_app/features/resources/domain/failures/reflections_failure.dart';

void main() {
  test('returns the body on HTTP 200, requesting only the approved page '
      "with the app's User-Agent", () async {
    Uri? url;
    String? userAgent;
    final datasource = ReflectionsPageDatasource(
      MockClient((request) async {
        url = request.url;
        userAgent = request.headers['User-Agent'];
        return http.Response('<html></html>', 200);
      }),
    );

    expect(await datasource.fetchPageHtml(), '<html></html>');
    expect(url, Uri.parse(ExternalLinks.dailyReflectionsPage));
    expect(url!.host, 'www.risenlordcommunity.com');
    expect(userAgent, startsWith('StLukesParishApp/'));
  });

  test('a non-200 status is a network failure', () {
    final datasource = ReflectionsPageDatasource(
      MockClient((_) async => http.Response('gone', 404)),
    );
    expect(
      datasource.fetchPageHtml(),
      throwsA(isA<ReflectionsNetworkFailure>()),
    );
  });

  test('a thrown client error is a network failure', () {
    final datasource = ReflectionsPageDatasource(
      MockClient((_) async => throw http.ClientException('offline')),
    );
    expect(
      datasource.fetchPageHtml(),
      throwsA(isA<ReflectionsNetworkFailure>()),
    );
  });
}
