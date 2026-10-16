import 'dart:typed_data';

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

  /// Downloads the image at [url], or returns `null` if it can't (offline,
  /// removed file, not an image), so callers can simply hide what would
  /// show it. Downloading up front also means the image appears instantly
  /// when it's opened.
  Future<Uint8List?> fetchImage(String url) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: const {'User-Agent': parishAppUserAgent},
          )
          .timeout(_timeout);
      final type = response.headers['content-type'] ?? '';
      if (response.statusCode != 200 || !type.startsWith('image/')) {
        return null;
      }
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }
}
