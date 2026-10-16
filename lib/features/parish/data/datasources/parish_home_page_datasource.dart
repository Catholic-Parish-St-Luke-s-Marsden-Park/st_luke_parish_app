import 'package:http/http.dart' as http;

import '../../../../core/constants/external_links.dart';
import '../../../../core/network/http_user_agent.dart';
import '../../domain/failures/parish_documents_failure.dart';

/// Fetches the parish home page HTML. Follows `BulletinsFeedDatasource`'s
/// pattern: bounded timeout, the app's descriptive `User-Agent` (the site's
/// firewall rejects generic clients) and a typed network failure on a
/// non-200 status or exception. No other layer calls `http` directly.
class ParishHomePageDatasource {
  ParishHomePageDatasource(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  Future<String> fetchHomePageHtml() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExternalLinks.parishHomePage),
            headers: const {'User-Agent': parishAppUserAgent},
          )
          .timeout(_timeout);
    } catch (e) {
      throw ParishDocumentsNetworkFailure(
        'Failed to reach the parish home page: $e',
      );
    }
    if (response.statusCode != 200) {
      throw ParishDocumentsNetworkFailure(
        'Parish home page returned HTTP ${response.statusCode}',
      );
    }
    return response.body;
  }

  /// Whether [url] currently serves an image, checked with a light `HEAD`
  /// request. Any failure (offline, removed file, not an image) counts as
  /// "no", so callers can simply hide what would show it.
  Future<bool> isImageAvailable(String url) async {
    try {
      final response = await _client
          .head(
            Uri.parse(url),
            headers: const {'User-Agent': parishAppUserAgent},
          )
          .timeout(_timeout);
      final type = response.headers['content-type'] ?? '';
      return response.statusCode == 200 && type.startsWith('image/');
    } catch (_) {
      return false;
    }
  }
}
