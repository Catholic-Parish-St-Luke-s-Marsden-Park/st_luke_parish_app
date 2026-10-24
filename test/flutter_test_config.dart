import 'dart:async';

import 'package:st_luke_parish_app/app/shell/widgets/pulsing_nav_icon.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/rosary_diagram.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/broadcasting_megaphone.dart';
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
///
/// Also disables [PulsingNavIcon]'s pulse animation for the whole suite.
/// That icon's `AnimationController.repeat()` never settles, which would
/// otherwise make `WidgetTester.pumpAndSettle()` time out in every widget
/// test that builds the full `AppShell` -- not just tests that specifically
/// exercise the Donate nav icon.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WebViewPlatform.instance = FakeWebViewPlatform();
  PulsingNavIcon.disableForTesting = true;
  BroadcastingMegaphone.disableForTesting = true;
  RosaryDiagram.disableForTesting = true;
  await testMain();
}
