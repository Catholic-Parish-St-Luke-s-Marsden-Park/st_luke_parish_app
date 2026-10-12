import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

import '../saint_json_fixtures.dart';

/// REQ-F09-001, REQ-F09-002, REQ-F09-003, REQ-F09-005, REQ-F09-006 and
/// REQ-F09-007.
void main() {
  final base = Uri.parse('https://api.example.org');
  const dateKey = '2026-10-12';
  const problemHeaders = {'content-type': 'application/problem+json'};

  SaintOfTheDayRemoteDatasource datasource(
    MockClientHandler handler, {
    bool noBase = false,
    SaintRequestHeadersBuilder? extraHeaders,
  }) => SaintOfTheDayRemoteDatasource(
    MockClient(handler),
    baseUri: noBase ? null : base,
    extraHeaders: extraHeaders,
  );

  Future<void> expectFailure<T extends SaintOfTheDayFailure>(
    MockClientHandler handler, {
    List<String> messageContains = const [],
  }) async {
    var matcher = isA<T>();
    for (final part in messageContains) {
      matcher = matcher.having((f) => f.message, 'message', contains(part));
    }
    await expectLater(
      datasource(handler).fetchSaintJson(dateKey),
      throwsA(matcher),
    );
  }

  test('GETs {base}/v1/saints/{dateKey} with JSON and User-Agent headers '
      'and no extra headers by default', () async {
    late http.Request sent;
    final body = await datasource((request) async {
      sent = request;
      return http.Response(saintJson(), 200);
    }).fetchSaintJson(dateKey);

    expect(body, saintJson());
    expect(sent.method, 'GET');
    expect(sent.url.toString(), 'https://api.example.org/v1/saints/2026-10-12');
    expect(sent.headers['Accept'], 'application/json');
    expect(sent.headers['User-Agent'], startsWith('StLukesParishApp/'));
    expect(sent.headers.containsKey('X-Firebase-AppCheck'), isFalse);
  });

  test('never requests /v1/saints/today', () async {
    late Uri sent;
    await datasource((request) async {
      sent = request.url;
      return http.Response(saintJson(dateKey: '2026-10-13'), 200);
    }).fetchSaintJson('2026-10-13');

    expect(sent.path, '/v1/saints/2026-10-13');
    expect(sent.path, isNot(contains('today')));
  });

  test('sends injected extra headers (future App Check token)', () async {
    late http.Request sent;
    await datasource(
      (request) async {
        sent = request;
        return http.Response(saintJson(), 200);
      },
      extraHeaders: () async => {'X-Firebase-AppCheck': 'token-123'},
    ).fetchSaintJson(dateKey);

    expect(sent.headers['X-Firebase-AppCheck'], 'token-123');
  });

  test('decodes UTF-8 from the raw bytes even without a charset', () async {
    final text = saintJson(overrides: {'name': 'Saint Thérèse of Lisieux'});
    final body = await datasource(
      (request) async => http.Response.bytes(
        utf8.encode(text),
        200,
        headers: {'content-type': 'application/json'},
      ),
    ).fetchSaintJson(dateKey);

    expect(body, text);
  });

  test('invalid UTF-8 in a 200 is a parsing failure', () async {
    await expectFailure<SaintOfTheDayParsingFailure>(
      (request) async => http.Response.bytes([0xff, 0xfe, 0xfd], 200),
    );
  });

  test('with no base URI, throws not-configured without a request', () async {
    var requests = 0;
    await expectLater(
      datasource((request) async {
        requests++;
        return http.Response(saintJson(), 200);
      }, noBase: true).fetchSaintJson(dateKey),
      throwsA(
        isA<SaintOfTheDayNotConfiguredFailure>().having(
          (f) => f.message,
          'message',
          contains('API_BASE_URL'),
        ),
      ),
    );
    expect(requests, 0);
  });

  group('failure mapping (REQ-F09-006)', () {
    test('503 saint_not_ready is NotReady', () async {
      await expectFailure<SaintOfTheDayNotReadyFailure>(
        (request) async => http.Response(
          problemJson(status: 503, code: 'saint_not_ready', requestId: 'r-1'),
          503,
          headers: problemHeaders,
        ),
        messageContains: ['503', 'saint_not_ready', 'r-1', dateKey],
      );
    });

    test('404 saint_not_available is DateUnavailable', () async {
      await expectFailure<SaintOfTheDayDateUnavailableFailure>(
        (request) async => http.Response(
          problemJson(status: 404, code: 'saint_not_available'),
          404,
          headers: problemHeaders,
        ),
        messageContains: ['404', 'saint_not_available', dateKey],
      );
    });

    test(
      '404 without a problem body is Unavailable, not a clock problem',
      () async {
        await expectFailure<SaintOfTheDayUnavailableFailure>(
          (request) async => http.Response('Not Found', 404),
        );
      },
    );

    test('404 with another code is Unavailable, not a clock problem', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async => http.Response(
          problemJson(status: 404, code: 'not_found', requestId: 'req-404'),
          404,
          headers: problemHeaders,
        ),
        messageContains: ['404', 'not_found', 'req-404'],
      );
    });

    test('401 app_check_required is Unavailable', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async => http.Response(
          problemJson(
            status: 401,
            code: 'app_check_required',
            requestId: 'req-401',
          ),
          401,
          headers: problemHeaders,
        ),
        messageContains: ['401', 'app_check_required', 'req-401'],
      );
    });

    test('400 invalid_date is Unavailable', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async => http.Response(
          problemJson(status: 400, code: 'invalid_date'),
          400,
          headers: problemHeaders,
        ),
        messageContains: ['400', 'invalid_date'],
      );
    });

    test('503 with another code is Unavailable, not NotReady', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async => http.Response(
          problemJson(status: 503, code: 'maintenance'),
          503,
          headers: problemHeaders,
        ),
        messageContains: ['503', 'maintenance'],
      );
    });

    test('503 with a non-JSON body is Unavailable', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async =>
            http.Response('<html>Service Unavailable</html>', 503),
        messageContains: ['503', 'code=none', 'requestId=none'],
      );
    });

    for (final status in [500, 502, 204, 302, 429]) {
      test('HTTP $status is Unavailable', () async {
        await expectFailure<SaintOfTheDayUnavailableFailure>(
          (request) async => http.Response('', status),
          messageContains: ['$status'],
        );
      });
    }

    test('a problem body without requestId logs requestId=none', () async {
      await expectFailure<SaintOfTheDayUnavailableFailure>(
        (request) async => http.Response(
          problemJson(status: 500, code: 'internal'),
          500,
          headers: problemHeaders,
        ),
        messageContains: ['code=internal', 'requestId=none'],
      );
    });

    test('a transport error is a network failure', () async {
      await expectFailure<SaintOfTheDayNetworkFailure>(
        (request) async => throw http.ClientException('offline'),
        messageContains: [dateKey],
      );
    });

    test('a failing header builder is a network failure', () async {
      await expectLater(
        datasource(
          (request) async => http.Response(saintJson(), 200),
          extraHeaders: () async => throw StateError('no token'),
        ).fetchSaintJson(dateKey),
        throwsA(isA<SaintOfTheDayNetworkFailure>()),
      );
    });

    // testWidgets for its fake clock, so the 10s timeout fires instantly.
    testWidgets('a timeout after 10s is a network failure', (tester) async {
      Object? error;
      unawaited(
        datasource((request) => Completer<http.Response>().future)
            .fetchSaintJson(dateKey)
            .then<void>(
              (_) {},
              onError: (Object e) {
                error = e;
              },
            ),
      );

      await tester.pump(const Duration(seconds: 9));
      expect(error, isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(error, isA<SaintOfTheDayNetworkFailure>());
    });
  });
}
