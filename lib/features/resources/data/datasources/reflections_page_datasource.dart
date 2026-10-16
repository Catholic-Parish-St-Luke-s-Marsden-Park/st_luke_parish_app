import 'package:http/http.dart' as http;

import '../../../../core/constants/external_links.dart';
import '../../domain/failures/reflections_failure.dart';

/// Fetches the Risen Lord Community's "On Our Knees" page (ADR-0009), with a
/// bounded timeout and the app's descriptive `User-Agent`, like the parish
/// website datasources. No other layer calls `http` directly.
class ReflectionsPageDatasource {
  ReflectionsPageDatasource(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);
  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  Future<String> fetchPageHtml() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(ExternalLinks.dailyReflectionsPage),
            headers: const {'User-Agent': _userAgent},
          )
          .timeout(_timeout);
    } catch (e) {
      throw ReflectionsNetworkFailure(
        'Failed to reach the reflections page: $e',
      );
    }
    if (response.statusCode != 200) {
      throw ReflectionsNetworkFailure(
        'Reflections page returned HTTP ${response.statusCode}',
      );
    }
    return response.body;
  }
}
