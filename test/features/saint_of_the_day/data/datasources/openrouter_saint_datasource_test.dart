import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/openrouter_saint_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

/// Direct unit tests for [OpenRouterSaintDatasource] (REQ-F06-002,
/// REQ-F06-003, REQ-F06-004, REQ-F06-005), using the constructor's
/// injectable `apiKey` parameter so these never depend on
/// `--dart-define` being set for `flutter test`.
void main() {
  group('isConfigured / not-configured failure', () {
    test('isConfigured is false with an empty key', () {
      final datasource = OpenRouterSaintDatasource(http.Client(), apiKey: '');

      expect(datasource.isConfigured, isFalse);
    });

    test('fetchSaintText throws SaintOfTheDayNotConfiguredFailure without '
        'sending a request when the key is empty', () async {
      var requested = false;
      final client = MockClient((request) async {
        requested = true;
        return http.Response('{}', 200);
      });
      final datasource = OpenRouterSaintDatasource(client, apiKey: '');

      await expectLater(
        datasource.fetchSaintText('Tuesday, September 1, 2026'),
        throwsA(isA<SaintOfTheDayNotConfiguredFailure>()),
      );
      expect(requested, isFalse);
    });
  });

  group('fetchSaintText — success', () {
    test('sends the expected request and returns the model text', () async {
      Uri? requestedUri;
      Map<String, String>? headers;
      Map<String, dynamic>? body;
      final client = MockClient((request) async {
        requestedUri = request.url;
        headers = request.headers;
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': '**SAINT NAME:**\nSaint Example\n'},
              },
            ],
          }),
          200,
        );
      });
      final datasource = OpenRouterSaintDatasource(
        client,
        apiKey: 'fake-test-key',
      );

      final text = await datasource.fetchSaintText(
        'Tuesday, September 1, 2026',
      );

      expect(text, '**SAINT NAME:**\nSaint Example\n');
      expect(
        requestedUri,
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      );
      expect(headers?['Authorization'], 'Bearer fake-test-key');
      expect(body?['model'], 'google/gemini-3.1-flash-lite');
      expect(body?['max_tokens'], 1000);
      expect(body?['temperature'], 0.3);
      final messages = body?['messages'] as List;
      expect(
        (messages.first as Map)['content'],
        contains('Tuesday, September 1, 2026'),
      );
    });
  });

  group('fetchSaintText — failure modes', () {
    test(
      'a non-200 response is converted to SaintOfTheDayNetworkFailure',
      () async {
        final client = MockClient((request) async {
          return http.Response('error', 401);
        });
        final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

        await expectLater(
          datasource.fetchSaintText('Tuesday, September 1, 2026'),
          throwsA(isA<SaintOfTheDayNetworkFailure>()),
        );
      },
    );

    test(
      'a thrown client exception is converted to SaintOfTheDayNetworkFailure',
      () async {
        final client = MockClient((request) async {
          throw Exception('socket closed');
        });
        final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

        await expectLater(
          datasource.fetchSaintText('Tuesday, September 1, 2026'),
          throwsA(isA<SaintOfTheDayNetworkFailure>()),
        );
      },
    );

    test(
      'a response with no choices is converted to SaintOfTheDayParsingFailure',
      () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode({'choices': <dynamic>[]}), 200);
        });
        final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

        await expectLater(
          datasource.fetchSaintText('Tuesday, September 1, 2026'),
          throwsA(isA<SaintOfTheDayParsingFailure>()),
        );
      },
    );

    test(
      'a non-JSON response body is converted to SaintOfTheDayParsingFailure',
      () async {
        final client = MockClient((request) async {
          return http.Response('not json', 200);
        });
        final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

        await expectLater(
          datasource.fetchSaintText('Tuesday, September 1, 2026'),
          throwsA(isA<SaintOfTheDayParsingFailure>()),
        );
      },
    );
  });

  group('fetchSaintText — unexpected response shapes', () {
    // Each of these used to throw a raw TypeError out of the datasource,
    // which the repository relabelled as a *network* failure — so the
    // user was told to check their connection over a response-shape
    // problem. They must surface as parsing failures instead.
    Future<void> expectParsingFailureFor(Object choices) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'choices': choices}), 200);
      });
      final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

      await expectLater(
        datasource.fetchSaintText('Tuesday, September 1, 2026'),
        throwsA(isA<SaintOfTheDayParsingFailure>()),
      );
    }

    test('`choices` as an object rather than a list', () async {
      await expectParsingFailureFor({'message': 'nope'});
    });

    test('a first choice that is not an object', () async {
      await expectParsingFailureFor(['just a string']);
    });

    test('`content` as a list of parts rather than a string', () async {
      // Some providers/models return structured content parts.
      await expectParsingFailureFor([
        {
          'message': {
            'content': [
              {'type': 'text', 'text': 'Saint X'},
            ],
          },
        },
      ]);
    });

    test('a whitespace-only content string', () async {
      // `isEmpty` alone let this through; the guard needs `trim`.
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': '\n\n   \t '},
              },
            ],
          }),
          200,
        );
      });
      final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

      await expectLater(
        datasource.fetchSaintText('Tuesday, September 1, 2026'),
        throwsA(isA<SaintOfTheDayParsingFailure>()),
      );
    });
  });

  group('fetchSaintText — response encoding', () {
    test('decodes UTF-8 content when the response declares no charset', () {
      // Characterisation test, not a regression guard: `http` 1.6.0
      // already defaults `application/json` with no charset to UTF-8, so
      // this passes with `response.body` too. It pins the behaviour that
      // matters — non-ASCII saint names survive the round trip — so a
      // future change to the decoding (or to that package default) has
      // to stay correct.
      const saintText =
          '**SAINT NAME:**\nSainte Thérèse de Lisieux\n'
          '**ABOUT:**\nThe Curé d\'Ars — "a soul on fire".\n';

      final payload = jsonEncode({
        'choices': [
          {
            'message': {'content': saintText},
          },
        ],
      });

      final client = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(payload),
          200,
          // Deliberately no `charset=utf-8`, matching OpenRouter.
          headers: {'content-type': 'application/json'},
        );
      });
      final datasource = OpenRouterSaintDatasource(client, apiKey: 'key');

      expect(
        datasource.fetchSaintText('Tuesday, September 1, 2026'),
        completion(
          allOf(
            contains('Thérèse'),
            contains('Curé'),
            contains('—'),
            isNot(contains('Ã')),
          ),
        ),
      );
    });
  });
}
