import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/failures/saint_of_the_day_failure.dart';

/// Calls OpenRouter directly from the app to generate today's saint
/// (REQ-F06-002) — per the user's explicit decision to call OpenRouter
/// directly rather than proxy through the existing Netlify function (see
/// ADR-0005 for the security trade-off this accepts).
///
/// The prompt and model are ported verbatim from the parish's live,
/// currently-deployed Netlify function (`netlify/functions/saint-of-day.mjs`
/// in the `stlukes-marsden-park-app` repo), so the content shape this app
/// receives matches what that proven implementation already produces.
class OpenRouterSaintDatasource {
  /// [apiKey] defaults to the compile-time environment value
  /// (REQ-F06-003) — never a literal string in source. Supply with, e.g.:
  /// `flutter run --dart-define=OPENROUTER_API_KEY=sk-or-...`. The
  /// constructor parameter exists so tests can inject a fake key without
  /// needing `--dart-define` at test time; production call sites should
  /// never pass this explicitly.
  OpenRouterSaintDatasource(
    this._client, {
    String apiKey = const String.fromEnvironment('OPENROUTER_API_KEY'),
  }) : _apiKey = apiKey;

  final http.Client _client;
  final String _apiKey;

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'google/gemini-3.1-flash-lite';
  static const _timeout = Duration(seconds: 20);

  static const _appReferer = 'https://stlukesmarsdenpark.org.au';
  static const _appTitle = "St Luke's Parish App";

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Requests today's saint content for [fullDate] (e.g. "Tuesday, 1
  /// September 2026"), formatted the same way the reference Netlify
  /// function formats its `fullDate` prompt input. Returns the model's raw
  /// text response, unparsed.
  Future<String> fetchSaintText(String fullDate) async {
    if (!isConfigured) {
      throw const SaintOfTheDayNotConfiguredFailure(
        'OPENROUTER_API_KEY was not supplied at build/run time.',
      );
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'HTTP-Referer': _appReferer,
              'X-Title': _appTitle,
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': _prompt(fullDate)},
              ],
              'max_tokens': 1000,
              'temperature': 0.3,
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      throw SaintOfTheDayNetworkFailure('Failed to reach OpenRouter: $e');
    }

    if (response.statusCode != 200) {
      throw SaintOfTheDayNetworkFailure(
        'OpenRouter returned HTTP ${response.statusCode}',
      );
    }

    // Decoded explicitly rather than via `response.body`. Not a bug fix:
    // `http` 1.6.0 already special-cases `application/json` with no
    // charset to UTF-8, which is exactly what OpenRouter sends. This
    // just removes the dependence on that behaviour — `response.body`
    // falls back to *latin1* for any other content type, so a proxy or
    // gateway answering `text/plain` would turn "Thérèse" into
    // "ThÃ©rÃ¨se" and cache the mojibake for the whole day. JSON is
    // UTF-8 by spec (RFC 8259), so decode the bytes as UTF-8 outright.
    final String body;
    try {
      body = utf8.decode(response.bodyBytes);
    } catch (e) {
      throw SaintOfTheDayParsingFailure(
        'OpenRouter response was not valid UTF-8: $e',
      );
    }

    // Everything that reads into the response envelope is inside this
    // try: `choices` may be absent or not a list, its first element may
    // not be an object, and `content` is a list of parts rather than a
    // string on some providers/models. Left outside, any of those threw a
    // raw TypeError that escaped as an untyped error and was relabelled
    // downstream as a *network* failure — so the user was told to check
    // their connection over a response-shape problem.
    final String? text;
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const SaintOfTheDayParsingFailure(
          'No content returned from the model.',
        );
      }
      final message =
          (choices.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>?;
      text = message?['content'] as String?;
    } on SaintOfTheDayFailure {
      rethrow;
    } catch (e) {
      throw SaintOfTheDayParsingFailure(
        'OpenRouter response had an unexpected shape: $e',
      );
    }

    // `trim`, not a bare `isEmpty`: a truncated or refused generation can
    // come back as whitespace only, which would otherwise sail past the
    // one guard that exists to catch it.
    if (text == null || text.trim().isEmpty) {
      throw const SaintOfTheDayParsingFailure(
        'No content returned from the model.',
      );
    }

    return text;
  }

  /// Ported verbatim (structure and section headers) from the reference
  /// Netlify function's `SAINT_PROMPT`, so the response shape matches what
  /// `SaintTextParser` expects.
  static String _prompt(String date) =>
      '''
Today is $date. You are a Catholic scholar with deep knowledge of the Vatican's Roman Martyrology and the General Roman Calendar.

Please provide comprehensive information about the Catholic Saint(s) celebrated today in the following structured format. Use the exact section headers below:

**SAINT NAME:**
[Full name and title e.g. Saint John Vianney, Priest]

**FEAST DAY:**
[Date and liturgical rank e.g. August 4 - Optional Memorial]

**BORN & DIED:**
[Birth year/place - Death year/place]

**ABOUT:**
[3-4 sentences about their life, mission and significance in the Church]

**FAMOUS SAYING:**
[One of their most well-known quotes or sayings, in quotation marks]

**DID YOU KNOW:**
[One fascinating, lesser-known fact about this saint]

**PATRON OF:**
[List what/who they are patron saint of]

**PRAYER:**
[A short traditional prayer to this saint, 2-3 sentences]

If multiple saints are celebrated today, focus on the most prominent one. Base your response strictly on authentic Catholic Church records and Vatican documentation.''';
}
