import 'package:http/http.dart' as http;

import '../../../../core/constants/external_links.dart';
import '../../domain/failures/events_failure.dart';

/// Fetches the live AI1EC calendar feed (REQ-F08-001). Mirrors
/// `BulletinsFeedDatasource`'s pattern exactly: bounded timeout, the same
/// custom `User-Agent` convention (also confirmed in production use by this
/// same parish's other app, `stlukes-marsden-park-app`'s
/// `netlify/functions/events.mjs`), typed network failure on
/// non-200/exception. No other layer calls `http` directly.
class ParishEventsFeedDatasource {
  ParishEventsFeedDatasource(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);
  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  Future<String> fetchFeedIcs() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExternalLinks.eventsFeed),
            headers: const {'User-Agent': _userAgent},
          )
          .timeout(_timeout);
    } catch (e) {
      throw EventsNetworkFailure('Failed to reach the events feed: $e');
    }
    if (response.statusCode != 200) {
      throw EventsNetworkFailure(
        'Events feed returned HTTP ${response.statusCode}',
      );
    }
    return response.body;
  }
}
