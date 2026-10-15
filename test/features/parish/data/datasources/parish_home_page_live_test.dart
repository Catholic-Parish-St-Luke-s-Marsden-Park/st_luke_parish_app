// Real-network test: excluded from offline runs with
// `flutter test --exclude-tags live` (see dart_test.yaml).
@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_documents_repository.dart';

/// Live check against the real parish home page: the Pastoral Council
/// minutes button is still there and still points at a document. The exact
/// file changes every month, so only its shape is asserted.
void main() {
  test('the real home page links to the Pastoral Council minutes', () async {
    final client = http.Client();
    addTearDown(client.close);
    final repository = WebsiteParishDocumentsRepository(
      ParishHomePageDatasource(client),
    );

    final url = Uri.parse(await repository.getLatestCouncilMinutesUrl());

    expect(url.scheme, 'https');
    expect(url.host, 'stlukesmarsdenpark.org.au');
    expect(url.path.toLowerCase(), contains('minutes'));
  }, timeout: const Timeout(Duration(seconds: 30)));
}
