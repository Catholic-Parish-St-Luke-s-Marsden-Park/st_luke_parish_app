import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A fake [WebViewPlatform] implementation for widget tests.
///
/// `webview_flutter` requires a registered [WebViewPlatform.instance]
/// before any [WebViewController]/[WebViewWidget] can be constructed —
/// normally provided by platform plugin registration on a real device,
/// which does not happen in the widget-test harness. This fake registers a
/// no-op platform so widget tests can build screens containing a
/// `WebViewWidget` without crashing, and exposes the last-created
/// navigation delegate so tests can manually simulate
/// `onPageStarted`/`onPageFinished`/`onWebResourceError` callbacks to cover
/// the Donate WebView's loading/success/failure states.
///
/// Registered globally for all test files via `test/flutter_test_config.dart`
/// so any widget test that builds `AppShell`, `DonateScreen`, or
/// `SimpleWebViewScreen` (directly or indirectly, e.g. by cycling through
/// bottom-nav tabs) can do so safely.
class FakeWebViewPlatform extends WebViewPlatform {
  FakeNavigationDelegate? lastNavigationDelegate;
  FakeWebViewController? lastController;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakeWebViewController(params);
    lastController = controller;
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakeWebViewWidget(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return FakeCookieManager(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    final delegate = FakeNavigationDelegate(params);
    lastNavigationDelegate = delegate;
    return delegate;
  }
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  String? lastLoadedUrl;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    lastLoadedUrl = params.uri.toString();
  }

  @override
  Future<String?> currentUrl() async => lastLoadedUrl;
}

class FakeCookieManager extends PlatformWebViewCookieManager {
  FakeCookieManager(super.params) : super.implementation();
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

/// Captures the `onPageStarted`/`onPageFinished`/`onWebResourceError`
/// callbacks registered by `SimpleWebViewScreen` so tests can invoke them
/// directly to simulate WebView lifecycle events.
class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(super.params) : super.implementation();

  PageEventCallback? onPageStarted;
  PageEventCallback? onPageFinished;
  WebResourceErrorCallback? onWebResourceError;

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    onPageStarted = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    onPageFinished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    onWebResourceError = callback;
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback handler) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}
}
