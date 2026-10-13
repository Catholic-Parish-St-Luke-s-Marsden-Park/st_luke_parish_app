import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/config/api_base_uri_provider.dart';

/// REQ-F08-006 and REQ-F08-007: resolving the parish API origin.
void main() {
  group('resolveApiBaseUri', () {
    Uri? resolve({String? api, bool isRelease = false}) =>
        resolveApiBaseUri(apiBaseUrl: api, isRelease: isRelease);

    test('accepts an https origin', () {
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

    test('unset API_BASE_URL resolves to null', () {
      expect(resolve(), isNull);
    });

    test('blank API_BASE_URL resolves to null', () {
      expect(resolve(api: '   '), isNull);
    });

    test('an invalid API_BASE_URL resolves to null', () {
      expect(resolve(api: 'not a url'), isNull);
    });

    test('a non-http(s) scheme is rejected', () {
      expect(resolve(api: 'ftp://api.example.org'), isNull);
    });

    test('http is rejected in release builds', () {
      expect(resolve(api: 'http://api.example.org', isRelease: true), isNull);
    });

    test('https is accepted in release builds', () {
      expect(
        resolve(api: 'https://api.example.org', isRelease: true).toString(),
        'https://api.example.org',
      );
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
        envString: 'API_BASE_URL=https://parish-app-service.fly.dev',
      );

      expect(read().toString(), 'https://parish-app-service.fly.dev');
    });

    test('is null when API_BASE_URL is absent from the env', () {
      dotenv.loadFromString(envString: 'OTHER_KEY=value');

      expect(read(), isNull);
    });

    test('is null when assets/app.env never loaded', () {
      dotenv.clean();

      expect(read(), isNull);
    });
  });
}
