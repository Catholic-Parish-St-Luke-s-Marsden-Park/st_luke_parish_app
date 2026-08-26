import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cross-cutting contract for launching external URLs in the device's
/// external browser/app. Kept as an injectable abstraction (rather than a
/// direct static `url_launcher` call) so widget tests can override
/// [urlLauncherServiceProvider] with a fake and verify launch behavior
/// without touching platform channels.
abstract class UrlLauncherService {
  /// Validates and launches [url] externally. Returns `false` (without
  /// throwing) if the URL is invalid or cannot be launched.
  Future<bool> launchExternal(String url);
}

class UrlLauncherServiceImpl implements UrlLauncherService {
  const UrlLauncherServiceImpl();

  @override
  Future<bool> launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return false;
    }
    if (!await canLaunchUrl(uri)) {
      return false;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final urlLauncherServiceProvider = Provider<UrlLauncherService>((ref) {
  return const UrlLauncherServiceImpl();
});
