import 'dart:async';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'helpers/fake_webview_platform.dart';

/// Runs before every test file in this directory tree. Registers a fake
/// `webview_flutter` platform implementation so any widget test that
/// constructs a `WebViewController`/`WebViewWidget` (directly via
/// `SimpleWebViewScreen`/`DonateScreen`, or indirectly by building
/// `AppShell` and cycling to the Donate tab) does not crash with
/// "A platform implementation for 'webview_flutter' has not been set".
///
/// See `test/helpers/fake_webview_platform.dart` for the fake itself.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WebViewPlatform.instance = FakeWebViewPlatform();
  await testMain();
}
