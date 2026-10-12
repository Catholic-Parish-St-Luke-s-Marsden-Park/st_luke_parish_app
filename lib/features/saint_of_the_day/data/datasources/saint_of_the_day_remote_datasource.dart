import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/failures/saint_of_the_day_failure.dart';
import '../parsers/problem_details_parser.dart';

/// Supplies extra request headers per call, e.g. a future
/// `X-Firebase-AppCheck` token once the parish API enforces App Check
/// (REQ-F09-002). Nothing is supplied today.
typedef SaintRequestHeadersBuilder = Future<Map<String, String>> Function();

/// Fetches the raw `Saint` JSON for one Sydney date from the parish API's
/// public, read-only `GET /v1/saints/{date}` endpoint (REQ-F09-001). Every
/// transport problem, timeout or non-200 status is converted into a
/// [SaintOfTheDayFailure] here; nothing above the repository sees a raw
/// `http` exception. Mirrors `MinistriesRemoteDatasource`.
class SaintOfTheDayRemoteDatasource {
  SaintOfTheDayRemoteDatasource(
    this._client, {
    required Uri? baseUri,
    SaintRequestHeadersBuilder? extraHeaders,
  }) : _baseUri = baseUri,
       _extraHeaders = extraHeaders;

  final http.Client _client;

  /// API origin, or null when `API_BASE_URL`/`BASE_URL` is not configured.
  final Uri? _baseUri;
  final SaintRequestHeadersBuilder? _extraHeaders;

  static const _timeout = Duration(seconds: 10);

  static const _userAgent =
      'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';

  static const _notReadyCode = 'saint_not_ready';
  static const _notAvailableCode = 'saint_not_available';

  /// Body of `GET /v1/saints/{dateKey}`, decoded as UTF-8.
  ///
  /// Throws (REQ-F09-006):
  /// - [SaintOfTheDayNotConfiguredFailure] with no API origin, before any
  ///   request is made;
  /// - [SaintOfTheDayNetworkFailure] on a timeout or transport error;
  /// - [SaintOfTheDayNotReadyFailure] on 503 `saint_not_ready`;
  /// - [SaintOfTheDayDateUnavailableFailure] on 404 `saint_not_available`
  ///   only, so another 404 (an unknown route, a proxy page) is never
  ///   blamed on the phone's clock;
  /// - [SaintOfTheDayUnavailableFailure] on any other non-200;
  /// - [SaintOfTheDayParsingFailure] when a 200 body is not valid UTF-8.
  Future<String> fetchSaintJson(String dateKey) async {
    final baseUri = _baseUri;
    if (baseUri == null) {
      throw SaintOfTheDayNotConfiguredFailure(
        'No parish API origin for dateKey=$dateKey: set API_BASE_URL (or '
        'BASE_URL) in assets/app.env.',
      );
    }
    final uri = baseUri.replace(pathSegments: ['v1', 'saints', dateKey]);

    final http.Response response;
    try {
      final headers = {
        'Accept': 'application/json',
        'User-Agent': _userAgent,
        ...?await _extraHeaders?.call(),
      };
      response = await _client.get(uri, headers: headers).timeout(_timeout);
    } catch (e) {
      throw SaintOfTheDayNetworkFailure(
        'Failed to reach ${uri.path} (dateKey=$dateKey): $e',
      );
    }

    if (response.statusCode != 200) {
      throw _failureFor(response, uri, dateKey);
    }

    // Decoded from the raw bytes: `response.body` falls back to latin1 when
    // the Content-Type has no charset, which would garble accented names.
    try {
      return utf8.decode(response.bodyBytes);
    } on FormatException catch (e) {
      throw SaintOfTheDayParsingFailure(
        '${uri.path} (dateKey=$dateKey) response was not valid UTF-8: '
        '${e.message}',
      );
    }
  }

  SaintOfTheDayFailure _failureFor(
    http.Response response,
    Uri uri,
    String dateKey,
  ) {
    final status = response.statusCode;
    final problem = parseProblemDetails(
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
    final code = problem?.code;
    // Diagnostics only (REQ-F09-007): the screen maps the failure type to
    // its own fixed message and never shows this text.
    final message =
        '${uri.path} returned HTTP $status '
        '(dateKey=$dateKey, code=${code ?? 'none'}, '
        'requestId=${problem?.requestId ?? 'none'})';

    if (status == 503 && code == _notReadyCode) {
      return SaintOfTheDayNotReadyFailure(message);
    }
    if (status == 404 && code == _notAvailableCode) {
      return SaintOfTheDayDateUnavailableFailure(message);
    }
    return SaintOfTheDayUnavailableFailure(message);
  }
}
