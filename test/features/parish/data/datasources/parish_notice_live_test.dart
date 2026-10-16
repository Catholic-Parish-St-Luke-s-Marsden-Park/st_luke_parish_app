// Real-network test: excluded from offline runs with
// `flutter test --exclude-tags live` (see dart_test.yaml).
@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_notice_repository.dart';

/// Live check against the real parish home page. The parish may take its
/// pop-up down at any time, so "no notice" passes too; a notice, when
/// present, must be an image on the parish site.
void main() {
  test('the real home page pop-up, if any, is a parish-site image', () async {
    final client = http.Client();
    addTearDown(client.close);

    final notice = await WebsiteParishNoticeRepository(
      ParishHomePageDatasource(client),
    ).getCurrentNotice();

    if (notice != null) {
      final url = Uri.parse(notice.imageUrl);
      expect(url.scheme, 'https');
      expect(url.host, 'stlukesmarsdenpark.org.au');
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
