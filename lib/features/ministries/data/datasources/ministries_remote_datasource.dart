import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/failures/ministries_failure.dart';

/// Supplies extra request headers per call, e.g. a future
/// `X-Firebase-AppCheck` token once the parish API enforces App Check.
typedef RequestHeadersBuilder = Future<Map<String, String>> Function();

/// Fetches raw ministries JSON from the parish API's public, read-only
/// `/v1/ministries` endpoints. Every transport problem, timeout or non-200
/// status is converted into a [MinistriesFailure] here; nothing above the
/// repository sees a raw `http` exception.
class MinistriesRemoteDatasource {
  MinistriesRemoteDatasource(
    this._client, {
    required Uri? baseUri,
    RequestHeadersBuilder? extraHeaders,
  }) : _baseUri = baseUri,
       _extraHeaders = extraHeaders;

  final http.Client _client;

  /// API origin, or null when `API_BASE_URL` is not configured.
  final Uri? _baseUri;
  final RequestHeadersBuilder? _extraHeaders;

  static const _timeout = Duration(seconds: 10);

  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  /// Body of `GET /v1/ministries`.
  Future<String> fetchMinistriesJson() => _get(['v1', 'ministries']);

  /// Body of `GET /v1/ministries/{id}`. A 404 throws
  /// [MinistryNotFoundFailure].
  Future<String> fetchMinistryJson(String id) =>
      _get(['v1', 'ministries', id], notFoundIsMissingMinistry: true);

  Future<String> _get(
    List<String> pathSegments, {
    bool notFoundIsMissingMinistry = false,
  }) async {
    final baseUri = _baseUri;
    if (baseUri == null) {
      throw const MinistriesNotConfiguredFailure(
        'No parish API origin: set API_BASE_URL in assets/app.env.',
      );
    }
    final uri = baseUri.replace(pathSegments: pathSegments);

    final http.Response response;
    try {
      final headers = {
        'Accept': 'application/json',
        'User-Agent': _userAgent,
        ...?await _extraHeaders?.call(),
      };
      response = await _client.get(uri, headers: headers).timeout(_timeout);
    } catch (e) {
      throw MinistriesNetworkFailure('Failed to reach ${uri.path}: $e');
    }

    if (notFoundIsMissingMinistry && response.statusCode == 404) {
      throw MinistryNotFoundFailure('${uri.path} returned 404');
    }
    if (response.statusCode != 200) {
      throw MinistriesNetworkFailure(
        '${uri.path} returned HTTP ${response.statusCode}',
      );
    }

    // Decoded from the raw bytes: `response.body` falls back to latin1 when
    // the Content-Type has no charset, which would garble the `·` and `—`
    // in the copy.
    try {
      return utf8.decode(response.bodyBytes);
    } on FormatException catch (e) {
      throw MinistriesParsingFailure(
        '${uri.path} response was not valid UTF-8: ${e.message}',
      );
    }
  }
}
