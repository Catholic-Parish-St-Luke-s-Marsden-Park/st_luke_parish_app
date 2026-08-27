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

/// URI schemes that carry an authority/host component (e.g.
/// `https://example.com`). `tel:` and `mailto:` URIs are valid without one
/// (e.g. `tel:0285300173`, `mailto:someone@example.com`), so the host check
/// below only applies to schemes in this set.
const Set<String> _schemesRequiringHost = {'http', 'https'};

class UrlLauncherServiceImpl implements UrlLauncherService {
  const UrlLauncherServiceImpl();

  @override
  Future<bool> launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return false;
    }
    if (_schemesRequiringHost.contains(uri.scheme) && uri.host.isEmpty) {
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
