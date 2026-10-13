import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'backend_uri.dart';

part 'api_base_uri_provider.g.dart';

/// Origin of the parish API (parish_app_service), e.g.
/// `https://parish-app-service.fly.dev`, or null when it isn't configured.
///
/// Read from `API_BASE_URL` in assets/app.env. dotenv throws if
/// assets/app.env never loaded (main.dart logs and carries on), so that case
/// is treated as `API_BASE_URL` missing.
@Riverpod(keepAlive: true)
Uri? apiBaseUri(Ref ref) => resolveApiBaseUri(
  apiBaseUrl: dotenv.isInitialized ? dotenv.maybeGet('API_BASE_URL') : null,
  isRelease: kReleaseMode,
);

/// Resolves the API origin from the raw env value. Pure so the rules are
/// unit-testable without dotenv or kReleaseMode. Any path, query or fragment
/// on the raw value is dropped.
@visibleForTesting
Uri? resolveApiBaseUri({required String? apiBaseUrl, required bool isRelease}) {
  const envKey = 'API_BASE_URL';
  final uri = validateBackendUri(
    apiBaseUrl,
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
