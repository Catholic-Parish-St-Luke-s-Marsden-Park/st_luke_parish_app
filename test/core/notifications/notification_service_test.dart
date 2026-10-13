import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:st_luke_parish_app/core/notifications/notification_service.dart';

void main() {
  group('resolveBackendUri', () {
    test('returns null when the raw value is null or empty', () {
      expect(
        NotificationService.resolveBackendUri(null, isRelease: false),
        isNull,
      );
      expect(
        NotificationService.resolveBackendUri('   ', isRelease: false),
        isNull,
      );
    });

    test('returns null for a malformed URL', () {
      expect(
        NotificationService.resolveBackendUri('not a url', isRelease: false),
        isNull,
      );
    });

    test('accepts a valid http origin outside release mode', () {
      final uri = NotificationService.resolveBackendUri(
        'http://10.0.2.2:8080',
        isRelease: false,
      );

      expect(uri, Uri.parse('http://10.0.2.2:8080/v1/devices'));
    });

    test('rejects a non-https URL in release mode', () {
      expect(
        NotificationService.resolveBackendUri(
          'http://10.0.2.2:8080',
          isRelease: true,
        ),
        isNull,
      );
    });

    test('accepts an https URL in release mode', () {
      final uri = NotificationService.resolveBackendUri(
        'https://parish-app-service.fly.dev',
        isRelease: true,
      );

      expect(uri, Uri.parse('https://parish-app-service.fly.dev/v1/devices'));
    });

    test('trims whitespace and ignores a trailing slash or path', () {
      for (final raw in [
        '  https://parish-app-service.fly.dev  ',
        'https://parish-app-service.fly.dev/',
        'https://parish-app-service.fly.dev/v1/devices',
      ]) {
        expect(
          NotificationService.resolveBackendUri(raw, isRelease: true),
          Uri.parse('https://parish-app-service.fly.dev/v1/devices'),
          reason: raw,
        );
      }
    });
  });

  group('postToken', () {
    final uri = Uri.parse('https://example.onrender.com/v1/devices');

    test('returns true on a first-attempt 2xx response', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response('', 204);
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      final result = await service.postToken(uri, 'a-token');

      expect(result, isTrue);
      expect(callCount, 1);
    });

    test('sends the /v1/devices body', () async {
      Map<String, dynamic>? body;
      final client = MockClient((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('', 204);
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      await service.postToken(uri, 'a-token');

      expect(body!['fcmToken'], 'a-token');
      expect(body!['platform'], anyOf('android', 'ios'));
      expect(body!['locale'], isA<String>());
      expect(body!.containsKey('fcm_token'), isFalse);
      expect(body!.containsKey('topics'), isFalse);
    });

    test('does not retry a 400 or 401', () async {
      for (final status in [400, 401]) {
        var callCount = 0;
        final client = MockClient((request) async {
          callCount++;
          return http.Response(
            '{"code":"bad_request","requestId":"r1"}',
            status,
            headers: {'content-type': 'application/problem+json'},
          );
        });
        final service = NotificationService.forTesting(
          httpClient: client,
          isRelease: false,
        );

        final result = await service.postToken(uri, 'a-token');

        expect(result, isFalse, reason: 'status $status');
        expect(callCount, 1, reason: 'status $status');
      }
    });

    test('retries a 429, then succeeds', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return callCount == 1
            ? http.Response('{"code":"rate_limited"}', 429)
            : http.Response('', 204);
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      final result = await service.postToken(uri, 'a-token', maxRetries: 2);

      expect(result, isTrue);
      expect(callCount, 2);
    });

    test('retries on non-2xx responses, then gives up', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response('server error', 500);
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      final result = await service.postToken(uri, 'a-token', maxRetries: 2);

      expect(result, isFalse);
      expect(callCount, 2);
    });

    test('retries when the request throws, then gives up', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        throw http.ClientException('connection refused');
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      final result = await service.postToken(uri, 'a-token', maxRetries: 2);

      expect(result, isFalse);
      expect(callCount, 2);
    });

    test('succeeds after a retry once the server recovers', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return callCount == 1
            ? http.Response('server error', 500)
            : http.Response('', 204);
      });
      final service = NotificationService.forTesting(
        httpClient: client,
        isRelease: false,
      );

      final result = await service.postToken(uri, 'a-token', maxRetries: 2);

      expect(result, isTrue);
      expect(callCount, 2);
    });
  });

  group('sendTokenIfChanged', () {
    // Mirrors NotificationService._tokenPrefsKey.
    const prefsKey = 'last_registered_fcm_token';

    late List<Uri> requests;
    late int statusCode;

    NotificationService buildService({bool isRelease = false}) {
      final client = MockClient((request) async {
        requests.add(request.url);
        return http.Response('', statusCode);
      });
      return NotificationService.forTesting(
        httpClient: client,
        isRelease: isRelease,
      );
    }

    void setBaseUrl(String url) =>
        dotenv.loadFromString(envString: 'API_BASE_URL=$url');

    setUp(() {
      requests = [];
      statusCode = 204;
      SharedPreferences.setMockInitialValues({});
      setBaseUrl('https://example.onrender.com');
    });

    tearDown(dotenv.clean);

    test('posts a new token and caches it with the backend origin', () async {
      await buildService().sendTokenIfChanged('token-1');

      expect(requests, [Uri.parse('https://example.onrender.com/v1/devices')]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(prefsKey), 'token-1@https://example.onrender.com');
    });

    test('skips an unchanged token for the same backend', () async {
      final service = buildService();

      await service.sendTokenIfChanged('token-1');
      await service.sendTokenIfChanged('token-1');

      expect(requests, hasLength(1));
    });

    test('re-registers a new token for the same backend', () async {
      final service = buildService();

      await service.sendTokenIfChanged('token-1');
      await service.sendTokenIfChanged('token-2');

      expect(requests, hasLength(2));
    });

    test(
      're-registers the same token when API_BASE_URL moves to a new backend',
      () async {
        final service = buildService();
        await service.sendTokenIfChanged('token-1');

        setBaseUrl('https://parish-backend.example.org');
        await service.sendTokenIfChanged('token-1');

        expect(requests, [
          Uri.parse('https://example.onrender.com/v1/devices'),
          Uri.parse('https://parish-backend.example.org/v1/devices'),
        ]);
      },
    );

    test(
      'does not cache a failed registration, so the next call retries',
      () async {
        final service = buildService();
        statusCode = 500;

        await service.sendTokenIfChanged('token-1');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(prefsKey), isNull);
        final failedAttempts = requests.length;

        statusCode = 204;
        await service.sendTokenIfChanged('token-1');

        expect(requests, hasLength(failedAttempts + 1));
        expect(
          prefs.getString(prefsKey),
          'token-1@https://example.onrender.com',
        );
      },
    );

    test('sends nothing when API_BASE_URL is missing', () async {
      dotenv.loadFromString(envString: 'OTHER=1');

      await buildService().sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });

    test('sends nothing when assets/app.env never loaded', () async {
      dotenv.clean();

      await buildService().sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });

    test('sends nothing to a non-https API_BASE_URL in release mode', () async {
      setBaseUrl('http://10.0.2.2:8080');

      await buildService(isRelease: true).sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });
  });
}
