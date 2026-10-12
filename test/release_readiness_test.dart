import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against shipping a release build with assets/app.env still pointing
/// at the Android emulator loopback address, which is the committed default
/// for local development. NotificationService silently no-ops token
/// registration when API_BASE_URL isn't https in release mode (debugPrint is a
/// no-op in release builds), so the failure is otherwise invisible until
/// someone notices pushes never arrive.
///
/// assets/app.env legitimately holds the emulator URL day-to-day, so this
/// only runs when explicitly requested rather than as part of the normal
/// `flutter test` sweep. Run it before cutting a release build:
///   RELEASE_CHECK=true flutter test test/release_readiness_test.dart
void main() {
  final shouldRun = Platform.environment['RELEASE_CHECK'] == 'true';

  test(
    'assets/app.env API_BASE_URL is a release-ready https URL',
    () {
      final lines = File('assets/app.env').readAsLinesSync();
      final line = lines.firstWhere(
        (l) => l.trim().startsWith('API_BASE_URL='),
        orElse: () => fail('assets/app.env has no API_BASE_URL entry'),
      );
      final baseUrl = line.substring(line.indexOf('=') + 1).trim();

      expect(
        baseUrl,
        isNot(contains('10.0.2.2')),
        reason:
            'API_BASE_URL is still the Android emulator loopback address. Set '
            'it to the production backend URL before building for release '
            '— see README.md > Push notifications.',
      );
      expect(
        Uri.tryParse(baseUrl)?.scheme,
        'https',
        reason:
            'API_BASE_URL must use https for release builds; '
            'NotificationService rejects non-https URLs in release mode.',
      );
    },
    skip: shouldRun
        ? false
        : 'Only runs pre-release: set RELEASE_CHECK=true to enable.',
  );
}
