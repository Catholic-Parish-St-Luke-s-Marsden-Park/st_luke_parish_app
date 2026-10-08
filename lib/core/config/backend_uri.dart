import 'package:flutter/foundation.dart';

/// Validates a raw backend URL read from `assets/app.env`.
///
/// Returns null, with the reason logged, if [raw] is missing, malformed or
/// (in release builds) not https. [envKey] only names the setting in the
/// log line. Shared by `BASE_URL` (push token registration) and
/// `API_BASE_URL` (the parish API), so both follow the same rules.
Uri? validateBackendUri(
  String? raw, {
  required bool isRelease,
  required String envKey,
}) {
  final trimmed = raw?.trim();
  final uri = (trimmed == null || trimmed.isEmpty)
      ? null
      : Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    debugPrint('$envKey is missing or invalid in assets/app.env.');
    return null;
  }
  if (isRelease && uri.scheme != 'https') {
    debugPrint('$envKey must use https in release builds.');
    return null;
  }
  return uri;
}
