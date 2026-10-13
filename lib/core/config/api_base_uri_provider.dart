import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'backend_uri.dart';

part 'api_base_uri_provider.g.dart';

/// Origin of the parish API (parish_app_service), e.g.
/// `https://parish-app-service.fly.dev`, or null when it isn't configured.
///
/// Read from `API_BASE_URL` in assets/app.env. Until that is set, falls back
/// to the origin of `BASE_URL`, which holds the full `/tokens` endpoint on
/// the same service. dotenv throws if assets/app.env never loaded (main.dart
/// logs and carries on), so that case is treated as both keys missing.
@Riverpod(keepAlive: true)
Uri? apiBaseUri(Ref ref) => resolveApiBaseUri(
  apiBaseUrl: dotenv.isInitialized ? dotenv.maybeGet('API_BASE_URL') : null,
  legacyBaseUrl: dotenv.isInitialized ? dotenv.maybeGet('BASE_URL') : null,
  isRelease: kReleaseMode,
);

/// Resolves the API origin from the raw env values. Pure so the rules are
/// unit-testable without dotenv or kReleaseMode.
///
/// A set but invalid `API_BASE_URL` returns null rather than falling back,
/// so a typo is logged instead of silently pointing somewhere else.
@visibleForTesting
Uri? resolveApiBaseUri({
  required String? apiBaseUrl,
  required String? legacyBaseUrl,
  required bool isRelease,
}) {
  final useLegacy = apiBaseUrl == null || apiBaseUrl.trim().isEmpty;
  final envKey = useLegacy ? 'BASE_URL' : 'API_BASE_URL';
  final uri = validateBackendUri(
    useLegacy ? legacyBaseUrl : apiBaseUrl,
    isRelease: isRelease,
    envKey: envKey,
  );
  if (uri == null) return null;
  // Uri.origin throws for anything but http(s).
  if (!uri.isScheme('http') && !uri.isScheme('https')) {
    debugPrint('$envKey must be an http(s) URL.');
    return null;
  }
  return Uri.parse(uri.origin);
}
