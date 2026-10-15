import 'package:http/http.dart' as http;

import '../../../../core/constants/external_links.dart';
import '../../domain/failures/parish_documents_failure.dart';

/// Fetches the parish home page HTML. Follows `BulletinsFeedDatasource`'s
/// pattern: bounded timeout, the app's descriptive `User-Agent` (the site's
/// firewall rejects generic clients) and a typed network failure on a
/// non-200 status or exception. No other layer calls `http` directly.
class ParishHomePageDatasource {
  ParishHomePageDatasource(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);
  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  Future<String> fetchHomePageHtml() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExternalLinks.parishHomePage),
            headers: const {'User-Agent': _userAgent},
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
}
