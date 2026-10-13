import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/features/ministries/data/datasources/ministries_remote_datasource.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';

/// REQ-F08-001, REQ-F08-002, REQ-F08-005 and REQ-F08-008.
void main() {
  final base = Uri.parse('https://api.example.org');

  MinistriesRemoteDatasource datasource(
    MockClientHandler handler, {
    Uri? baseUri,
    bool noBase = false,
    RequestHeadersBuilder? extraHeaders,
  }) => MinistriesRemoteDatasource(
    MockClient(handler),
    baseUri: noBase ? null : (baseUri ?? base),
    extraHeaders: extraHeaders,
  );

  group('fetchMinistriesJson', () {
    test(
      'GETs {base}/v1/ministries with JSON and User-Agent headers',
      () async {
        late http.Request sent;
        final body = await datasource((request) async {
          sent = request;
          return http.Response('{"items": []}', 200);
        }).fetchMinistriesJson();

        expect(body, '{"items": []}');
        expect(sent.method, 'GET');
        expect(sent.url.toString(), 'https://api.example.org/v1/ministries');
        expect(sent.headers['Accept'], 'application/json');
        expect(sent.headers['User-Agent'], startsWith('StLukesParishApp/'));
      },
    );

    test('keeps a non-default port from the base', () async {
      late Uri sent;
      await datasource((request) async {
        sent = request.url;
        return http.Response('{}', 200);
      }, baseUri: Uri.parse('http://10.0.2.2:8080')).fetchMinistriesJson();

      expect(sent.toString(), 'http://10.0.2.2:8080/v1/ministries');
    });

    test('sends injected extra headers (future App Check token)', () async {
      late http.Request sent;
      await datasource(
        (request) async {
          sent = request;
          return http.Response('{}', 200);
        },
        extraHeaders: () async => {'X-Firebase-AppCheck': 'token-123'},
      ).fetchMinistriesJson();

      expect(sent.headers['X-Firebase-AppCheck'], 'token-123');
    });

    test('decodes UTF-8 from the raw bytes even without a charset', () async {
      const text = '{"time": "Sat 5:30pm · Sun 8am — St Luke’s"}';
      final body = await datasource(
        (request) async => http.Response.bytes(
          utf8.encode(text),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ).fetchMinistriesJson();

      expect(body, text);
    });

    test('invalid UTF-8 is a parsing failure', () async {
      await expectLater(
        datasource(
          (request) async => http.Response.bytes([0xff, 0xfe, 0xfd], 200),
        ).fetchMinistriesJson(),
        throwsA(isA<MinistriesParsingFailure>()),
      );
    });

    for (final status in [404, 500, 503]) {
      test('HTTP $status is a network failure', () async {
        await expectLater(
          datasource(
            (request) async => http.Response('nope', status),
          ).fetchMinistriesJson(),
          throwsA(
            isA<MinistriesNetworkFailure>().having(
              (f) => f.message,
              'message',
              contains('$status'),
            ),
          ),
        );
      });
    }

    test('a transport error is a network failure', () async {
      await expectLater(
        datasource(
          (request) async => throw http.ClientException('offline'),
        ).fetchMinistriesJson(),
        throwsA(isA<MinistriesNetworkFailure>()),
      );
    });

    // testWidgets for its fake clock, so the 10s timeout fires instantly.
    testWidgets('a timeout is a network failure', (tester) async {
      Object? error;
      unawaited(
        datasource(
          (request) => Completer<http.Response>().future,
        ).fetchMinistriesJson().then<void>(
          (_) {},
          onError: (Object e) {
            error = e;
          },
        ),
      );

      await tester.pump(const Duration(seconds: 9));
      expect(error, isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(error, isA<MinistriesNetworkFailure>());
    });

    test('a failing header builder is a network failure', () async {
      await expectLater(
        datasource(
          (request) async => http.Response('{}', 200),
          extraHeaders: () async => throw StateError('no token'),
        ).fetchMinistriesJson(),
        throwsA(isA<MinistriesNetworkFailure>()),
      );
    });

    test('with no base URI, throws not-configured without a request', () async {
      var requests = 0;
      await expectLater(
        datasource((request) async {
          requests++;
          return http.Response('{}', 200);
        }, noBase: true).fetchMinistriesJson(),
        throwsA(isA<MinistriesNotConfiguredFailure>()),
      );
      expect(requests, 0);
    });
  });

  group('fetchMinistryJson', () {
    test('GETs {base}/v1/ministries/{id}, encoding the id', () async {
      late Uri sent;
      await datasource((request) async {
        sent = request.url;
        return http.Response('{}', 200);
      }).fetchMinistryJson('a b/c');

      expect(
        sent.toString(),
        'https://api.example.org/v1/ministries/a%20b%2Fc',
      );
    });

    test('404 is MinistryNotFoundFailure', () async {
      await expectLater(
        datasource(
          (request) async => http.Response(
            '{"code": "ministry_not_found"}',
            404,
            headers: {'content-type': 'application/problem+json'},
          ),
        ).fetchMinistryJson('gone'),
        throwsA(isA<MinistryNotFoundFailure>()),
      );
    });

    test('other errors are network failures', () async {
      await expectLater(
        datasource(
          (request) async => http.Response('', 500),
        ).fetchMinistryJson('music'),
        throwsA(isA<MinistriesNetworkFailure>()),
      );
    });
  });
}
