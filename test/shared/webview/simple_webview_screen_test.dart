import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/shared/webview/simple_webview_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/fake_webview_platform.dart';

/// Covers the Donate WebView acceptance criteria: REQ-F03-022/023/025,
/// plus REQ-F03-029's required loading/success/failure WebView test-state
/// coverage. `WebViewPlatform.instance` is a fake registered globally in
/// `test/flutter_test_config.dart`.
void main() {
  FakeWebViewPlatform fakePlatform() =>
      WebViewPlatform.instance! as FakeWebViewPlatform;

  Future<void> pumpWebView(WidgetTester tester, {String? title}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimpleWebViewScreen(
            url: 'https://stlukesmarsdenpark.org.au/donate/',
            title: title,
          ),
        ),
      ),
    );
    // A single pump (not pumpAndSettle) so the initial loading state is
    // observable before any simulated navigation-delegate callback fires.
    await tester.pump();
  }

  group('REQ-F03-025: SimpleWebViewScreen lives under lib/shared/webview '
      'as a reusable widget', () {
    test('imported from package:st_luke_parish_app/shared/webview/... '
        '(this import compiling proves the location)', () {
      expect(true, isTrue);
    });
  });

  group('WebView loading state (REQ-F03-022, REQ-F03-029)', () {
    testWidgets('shows a loading indicator immediately after building, '
        'before the page finishes loading', (tester) async {
      await pumpWebView(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(WebViewWidget), findsOneWidget);
    });
  });

  group('WebView load-success state (REQ-F03-022, REQ-F03-029)', () {
    testWidgets('loading indicator is dismissed once onPageFinished fires', (
      tester,
    ) async {
      await pumpWebView(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      fakePlatform().lastNavigationDelegate!.onPageFinished!(
        'https://stlukesmarsdenpark.org.au/donate/',
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(WebViewWidget), findsOneWidget);
      expect(find.text('Unable to load this page'), findsNothing);
    });
  });

  group('WebView load-failure state (REQ-F03-023, REQ-F03-029)', () {
    testWidgets(
      'a main-frame onWebResourceError shows a user-visible error state, '
      'not raw exception text',
      (tester) async {
        await pumpWebView(tester);

        fakePlatform().lastNavigationDelegate!.onWebResourceError!(
          const WebResourceError(
            errorCode: -2,
            description: 'net::ERR_INTERNET_DISCONNECTED',
            isForMainFrame: true,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Unable to load this page'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
        // No raw exception/error-code text shown to the user.
        expect(find.textContaining('ERR_INTERNET_DISCONNECTED'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        // The underlying WebViewWidget is hidden while the error state
        // is shown.
        expect(find.byType(WebViewWidget), findsNothing);
      },
    );

    testWidgets('a non-main-frame resource error is ignored (no error state)', (
      tester,
    ) async {
      await pumpWebView(tester);

      fakePlatform().lastNavigationDelegate!.onWebResourceError!(
        const WebResourceError(
          errorCode: -2,
          description: 'blocked third-party script',
          isForMainFrame: false,
        ),
      );
      await tester.pump();

      expect(find.text('Unable to load this page'), findsNothing);
    });

    testWidgets('tapping "Try Again" retries the load and clears the error '
        'state', (tester) async {
      await pumpWebView(tester);

      fakePlatform().lastNavigationDelegate!.onWebResourceError!(
        const WebResourceError(
          errorCode: -2,
          description: 'net::ERR_INTERNET_DISCONNECTED',
          isForMainFrame: true,
        ),
      );
      await tester.pump();
      expect(find.text('Unable to load this page'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(find.text('Unable to load this page'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
