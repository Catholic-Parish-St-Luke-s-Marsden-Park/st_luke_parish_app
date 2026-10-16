// Real-network test: excluded from offline runs with
// `flutter test --exclude-tags live` (see dart_test.yaml).
@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_documents_repository.dart';

/// Live check against the real parish home page: the Pastoral Plan and
/// Pastoral Council minutes buttons are still there and still point at
/// documents. The exact files change, so only their shape is asserted.
void main() {
  test('the real home page links to the Pastoral Plan and Pastoral '
      'Council minutes', () async {
    final client = http.Client();
    addTearDown(client.close);
    final repository = WebsiteParishDocumentsRepository(
      ParishHomePageDatasource(client),
    );

    final links = await repository.getDocumentLinks();

    for (final (link, word) in [
      (links.pastoralPlanUrl, 'plan'),
      (links.councilMinutesUrl, 'minutes'),
    ]) {
      expect(link, isNotNull, reason: word);
      final url = Uri.parse(link!);
      expect(url.scheme, 'https');
      expect(url.host, 'stlukesmarsdenpark.org.au');
      expect(url.path.toLowerCase(), contains(word));
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
