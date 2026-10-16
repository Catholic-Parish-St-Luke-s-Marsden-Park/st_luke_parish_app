// Real-network test: excluded from offline runs with
// `flutter test --exclude-tags live` (see dart_test.yaml).
@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/resources/data/datasources/reflections_page_datasource.dart';
import 'package:st_luke_parish_app/features/resources/data/repositories/website_reflections_repository.dart';

/// Live check against the Risen Lord Community's "On Our Knees" page
/// (ADR-0009): it still lists monthly booklets the app can find. The exact
/// month changes, so only the shape is asserted.
void main() {
  test('the real page lists a recent monthly booklet', () async {
    final client = http.Client();
    addTearDown(client.close);
    final repository = WebsiteReflectionsRepository(
      ReflectionsPageDatasource(client),
    );

    final reflection = await repository.getLatestReflection();

    expect(Uri.parse(reflection.url).scheme, 'https');
    expect(reflection.url.toLowerCase(), endsWith('.pdf'));
    // The newest booklet out should be no more than a few months old.
    final now = DateTime.now();
    expect(
      reflection.month.isAfter(DateTime(now.year, now.month - 4)),
      isTrue,
      reason: 'newest listed: ${reflection.label}',
    );
  }, timeout: const Timeout(Duration(seconds: 30)));
}
