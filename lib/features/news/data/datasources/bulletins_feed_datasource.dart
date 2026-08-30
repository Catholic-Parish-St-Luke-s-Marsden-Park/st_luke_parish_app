import 'package:http/http.dart' as http;

import '../../../../core/constants/external_links.dart';
import '../../domain/failures/bulletins_failure.dart';

/// Fetches the raw WordPress bulletins-category RSS feed XML
/// (REQ-F05-001). Bounded by [_timeout]; never exposes a raw `http`
/// exception or non-2xx response to callers — both are converted into a
/// [BulletinsNetworkFailure] here. No screen/widget/provider calls `http`
/// directly; this datasource is only ever reached through
/// `FeedBulletinsRepository`.
class BulletinsFeedDatasource {
  BulletinsFeedDatasource(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// Identifies the app to the parish's WordPress host; some WAF/CDN
  /// configurations reject requests with no `User-Agent` header.
  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  Future<String> fetchFeedXml() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExternalLinks.bulletinsFeed),
            headers: const {'User-Agent': _userAgent},
          )
          .timeout(_timeout);
    } catch (e) {
      throw BulletinsNetworkFailure('Failed to reach the bulletins feed: $e');
    }

    if (response.statusCode != 200) {
      throw BulletinsNetworkFailure(
        'Bulletins feed returned HTTP ${response.statusCode}',
      );
    }

    return response.body;
  }
}
