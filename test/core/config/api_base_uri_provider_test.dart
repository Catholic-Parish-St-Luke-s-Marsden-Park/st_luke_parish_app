import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/config/api_base_uri_provider.dart';

/// REQ-F08-006 and REQ-F08-007: resolving the parish API origin.
void main() {
  group('resolveApiBaseUri', () {
    Uri? resolve({
      String? api,
      String? legacy = 'http://10.0.2.2:8080/tokens',
      bool isRelease = false,
    }) => resolveApiBaseUri(
      apiBaseUrl: api,
      legacyBaseUrl: legacy,
      isRelease: isRelease,
    );

    test('API_BASE_URL wins over BASE_URL', () {
      expect(
        resolve(api: 'https://parish-app-service.fly.dev').toString(),
        'https://parish-app-service.fly.dev',
      );
    });

    test('API_BASE_URL is reduced to its origin', () {
      expect(
        resolve(api: ' https://api.example.org/some/path/?q=1 ').toString(),
        'https://api.example.org',
      );
    });

    test('keeps a non-default port', () {
      expect(
        resolve(api: 'http://localhost:8080/').toString(),
        'http://localhost:8080',
      );
    });

    test('unset API_BASE_URL falls back to the origin of BASE_URL', () {
      expect(resolve().toString(), 'http://10.0.2.2:8080');
    });

    test('blank API_BASE_URL falls back to the origin of BASE_URL', () {
      expect(
        resolve(
          api: '   ',
          legacy: 'https://parish-app-service.fly.dev/tokens',
        ).toString(),
        'https://parish-app-service.fly.dev',
      );
    });

    test('a set but invalid API_BASE_URL does not fall back', () {
      expect(resolve(api: 'not a url'), isNull);
    });

    test('a non-http(s) scheme is rejected', () {
      expect(resolve(api: 'ftp://api.example.org'), isNull);
    });

    test('http is rejected in release builds', () {
      expect(resolve(api: 'http://api.example.org', isRelease: true), isNull);
    });

    test('an http BASE_URL fallback is rejected in release builds', () {
      expect(resolve(isRelease: true), isNull);
    });

    test('https is accepted in release builds', () {
      expect(
        resolve(api: 'https://api.example.org', isRelease: true).toString(),
        'https://api.example.org',
      );
    });

    test('both missing resolves to null', () {
      expect(resolve(legacy: null), isNull);
    });
  });

  group('apiBaseUriProvider', () {
    tearDown(dotenv.clean);

    Uri? read() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container.read(apiBaseUriProvider);
    }

    test('reads API_BASE_URL from the loaded env', () {
      dotenv.loadFromString(
        envString:
            'BASE_URL=http://10.0.2.2:8080/tokens\n'
            'API_BASE_URL=https://parish-app-service.fly.dev',
      );

      expect(read().toString(), 'https://parish-app-service.fly.dev');
    });

    test('falls back to BASE_URL when API_BASE_URL is absent', () {
      dotenv.loadFromString(envString: 'BASE_URL=http://10.0.2.2:8080/tokens');

      expect(read().toString(), 'http://10.0.2.2:8080');
    });

    test('is null when assets/app.env never loaded', () {
      dotenv.clean();

      expect(read(), isNull);
    });
  });
}
