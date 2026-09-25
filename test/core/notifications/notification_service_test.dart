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

    test('accepts a valid http URL outside release mode', () {
      final uri = NotificationService.resolveBackendUri(
        'http://10.0.2.2:8080/tokens',
        isRelease: false,
      );

      expect(uri, Uri.parse('http://10.0.2.2:8080/tokens'));
    });

    test('rejects a non-https URL in release mode', () {
      expect(
        NotificationService.resolveBackendUri(
          'http://10.0.2.2:8080/tokens',
          isRelease: true,
        ),
        isNull,
      );
    });

    test('accepts an https URL in release mode', () {
      final uri = NotificationService.resolveBackendUri(
        'https://example.onrender.com/tokens',
        isRelease: true,
      );

      expect(uri, Uri.parse('https://example.onrender.com/tokens'));
    });

    test('trims surrounding whitespace', () {
      final uri = NotificationService.resolveBackendUri(
        '  https://example.onrender.com/tokens  ',
        isRelease: true,
      );

      expect(uri, Uri.parse('https://example.onrender.com/tokens'));
    });
  });

  group('postToken', () {
    final uri = Uri.parse('https://example.onrender.com/tokens');

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
        dotenv.loadFromString(envString: 'BASE_URL=$url');

    setUp(() {
      requests = [];
      statusCode = 204;
      SharedPreferences.setMockInitialValues({});
      setBaseUrl('https://example.onrender.com/tokens');
    });

    tearDown(dotenv.clean);

    test('posts a new token and caches it with the backend origin', () async {
      await buildService().sendTokenIfChanged('token-1');

      expect(requests, [Uri.parse('https://example.onrender.com/tokens')]);
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
      're-registers the same token when BASE_URL moves to a new backend',
      () async {
        final service = buildService();
        await service.sendTokenIfChanged('token-1');

        setBaseUrl('https://parish-backend.example.org/tokens');
        await service.sendTokenIfChanged('token-1');

        expect(requests, [
          Uri.parse('https://example.onrender.com/tokens'),
          Uri.parse('https://parish-backend.example.org/tokens'),
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

    test('sends nothing when BASE_URL is missing', () async {
      dotenv.loadFromString(envString: 'OTHER=1');

      await buildService().sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });

    test('sends nothing when assets/app.env never loaded', () async {
      dotenv.clean();

      await buildService().sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });

    test('sends nothing to a non-https BASE_URL in release mode', () async {
      setBaseUrl('http://10.0.2.2:8080/tokens');

      await buildService(isRelease: true).sendTokenIfChanged('token-1');

      expect(requests, isEmpty);
    });
  });
}
