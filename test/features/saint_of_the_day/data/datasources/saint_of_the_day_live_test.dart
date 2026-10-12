import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/parsers/saint_json_parser.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/sydney_date.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

/// Live integration test against the production parish API (REQ-F09-022):
/// `GET https://parish-app-service.fly.dev/v1/saints/{today's Sydney key}`.
///
/// Requires network access (RISK-007 / RISK-F09-008): offline it fails as a
/// network failure, which is an environment limitation rather than a code
/// defect. Assertions are deliberately resilient, since the saint changes
/// daily. A 503 `saint_not_ready` (the server's daily job hasn't run yet,
/// e.g. just after Sydney midnight) skips rather than fails.
void main() {
  test(
    'today\'s saint can be fetched and parsed from the live parish API',
    () async {
      final client = http.Client();
      addTearDown(client.close);
      final datasource = SaintOfTheDayRemoteDatasource(
        client,
        baseUri: Uri.parse('https://parish-app-service.fly.dev'),
      );
      final dateKey = sydneyDateKey(sydneyNow());

      final String body;
      try {
        body = await datasource.fetchSaintJson(dateKey);
      } on SaintOfTheDayNotReadyFailure catch (e) {
        markTestSkipped('Saint for $dateKey not ready yet: ${e.message}');
        return;
      }
      final saint = parseSaintJson(body);

      expect(saint.name.trim(), isNotEmpty);
      expect(isWellFormedDateKey(saint.dateKey), isTrue);
      expect(saint.displayDate.trim(), isNotEmpty);
      expect(
        [
          saint.about,
          saint.bornDied,
          saint.saying,
          saint.didYouKnow,
          saint.patronOf,
          saint.prayer,
        ].any((section) => section.trim().isNotEmpty),
        isTrue,
        reason: 'at least one content section should be populated',
      );
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
