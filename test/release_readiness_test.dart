import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/config/api_base_uri_provider.dart';

/// Guards against shipping a release build with assets/app.env pointing at a
/// local backend (the Android emulator loopback address, or any non-https
/// origin) left over from development. NotificationService silently no-ops
/// token registration and the Ministries tab can't load when API_BASE_URL
/// isn't https in release mode (debugPrint is a no-op in release builds), so
/// the failure is otherwise invisible until someone notices pushes never
/// arrive.
///
/// assets/app.env may legitimately point at a local backend while developing,
/// so this only runs when explicitly requested rather than as part of the
/// normal `flutter test` sweep. Run it before cutting a release build:
///   RELEASE_CHECK=true flutter test test/release_readiness_test.dart
void main() {
  final shouldRun = Platform.environment['RELEASE_CHECK'] == 'true';

  test(
    'assets/app.env API_BASE_URL is a release-ready https origin',
    () {
      final lines = File('assets/app.env').readAsLinesSync();
      final line = lines.firstWhere(
        (l) => l.trim().startsWith('API_BASE_URL='),
        orElse: () => fail('assets/app.env has no API_BASE_URL entry'),
      );
      final apiBaseUrl = line.substring(line.indexOf('=') + 1).trim();

      expect(
        apiBaseUrl,
        isNot(contains('10.0.2.2')),
        reason:
            'API_BASE_URL is still the Android emulator loopback address. Set '
            'it to the production backend origin before building for release '
            '— see README.md > Push notifications.',
      );
      expect(
        resolveApiBaseUri(apiBaseUrl: apiBaseUrl, isRelease: true),
        isNotNull,
        reason:
            'API_BASE_URL must be an https origin for release builds; '
            'NotificationService and the Ministries tab reject anything else '
            'in release mode.',
      );
    },
    skip: shouldRun
        ? false
        : 'Only runs pre-release: set RELEASE_CHECK=true to enable.',
  );
}
