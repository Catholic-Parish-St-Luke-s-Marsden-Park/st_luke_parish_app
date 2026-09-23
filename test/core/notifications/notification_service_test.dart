import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
        NotificationService.resolveBackendUri(
          'not a url',
          isRelease: false,
        ),
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

      final result = await service.postToken(
        uri,
        'a-token',
        maxRetries: 2,
      );

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

      final result = await service.postToken(
        uri,
        'a-token',
        maxRetries: 2,
      );

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

      final result = await service.postToken(
        uri,
        'a-token',
        maxRetries: 2,
      );

      expect(result, isTrue);
      expect(callCount, 2);
    });
  });
}
