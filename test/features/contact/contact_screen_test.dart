import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/contact/data/config/static_contact_config.dart';
import 'package:st_luke_parish_app/features/contact/domain/entities/contact_item.dart';
import 'package:st_luke_parish_app/features/contact/presentation/screens/contact_screen.dart';
import 'package:st_luke_parish_app/features/contact/presentation/widgets/contact_tile.dart';
import 'package:st_luke_parish_app/shared/webview/simple_webview_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Covers the Contact tab acceptance criteria: REQ-F03-011..018.
class _FakeUrlLauncherService implements UrlLauncherService {
  _FakeUrlLauncherService({this.launchResult = true});

  final bool launchResult;
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return launchResult;
  }
}

void main() {
  Future<void> pumpContactScreen(
    WidgetTester tester, {
    required _FakeUrlLauncherService fakeLauncher,
  }) async {
    // ContactScreen's content (hero + map card + 8 tiles) is taller than
    // the default 800x600 test surface, which would leave later tiles
    // outside the SliverList's build/hit-test cache extent. Use a tall
    // surface so every tile is built and tappable without needing to
    // scroll mid-test.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [urlLauncherServiceProvider.overrideWithValue(fakeLauncher)],
        child: const MaterialApp(home: Scaffold(body: ContactScreen())),
      ),
    );
    // The embedded map preview's SimpleWebViewScreen shows an
    // indeterminate CircularProgressIndicator while "loading" -- the fake
    // WebView platform (test/helpers/fake_webview_platform.dart) never
    // fires onPageFinished on its own, so that spinner's animation never
    // settles and pumpAndSettle() would hang forever. A bounded pump is
    // sufficient to build the screen, same workaround already used for the
    // Donate tab's WebView in app_bar_chrome_test.dart.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Taps a widget rendering [text]. `pumpContactScreen` uses a tall test
  /// surface so every contact tile is already built and on-screen; this
  /// helper still funnels every tap through one place for consistency. Uses
  /// a bounded pump rather than pumpAndSettle for the same reason as
  /// `pumpContactScreen` above (the map preview's never-settling spinner).
  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group(
    'REQ-F03-011: ContactScreen renders real content, not a placeholder',
    () {
      testWidgets('does not render the generic PlaceholderScreen icon', (
        tester,
      ) async {
        await pumpContactScreen(
          tester,
          fakeLauncher: _FakeUrlLauncherService(),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Contact & Location'), findsOneWidget);
      });
    },
  );

  group('REQ-F03-012: static config has exactly 8 entries, in order, with '
      'exact values', () {
    test('exactly 8 entries in the exact expected order/values', () {
      expect(staticContactItems.length, 8);

      final expected = [
        (
          label: 'Phone',
          value: '(02) 8530 0173',
          action: ContactAction.call,
          actionTarget: 'tel:0285300173',
          subtitle: null,
        ),
        (
          label: 'Mobile',
          value: '0422 724 160',
          action: ContactAction.call,
          actionTarget: 'tel:0422724160',
          subtitle: null,
        ),
        (
          label: 'Email',
          value: 'marsdenpark@parracatholic.org',
          action: ContactAction.email,
          actionTarget: 'mailto:marsdenpark@parracatholic.org',
          subtitle: null,
        ),
        (
          label: 'Church Address',
          value: '55a Frontier Ave, Marsden Park NSW 2765',
          action: ContactAction.none,
          actionTarget: null,
          subtitle: 'Cnr Frontier Ave & Northbourne Dr',
        ),
        (
          label: 'Postal Address',
          value: 'PO Box 4045, Elara Village',
          action: ContactAction.none,
          actionTarget: null,
          subtitle: 'Marsden Park NSW 2765',
        ),
        (
          label: 'Office Hours',
          value: 'Monday – Friday · 9:30am – 4:30pm',
          action: ContactAction.none,
          actionTarget: null,
          subtitle: null,
        ),
        (
          label: 'Facebook',
          value: "St Luke's Catholic Parish Marsden Park",
          action: ContactAction.url,
          actionTarget: 'https://www.facebook.com/stlukesmarsdenpark/',
          subtitle: null,
        ),
        (
          label: 'Website',
          value: 'stlukesmarsdenpark.org.au',
          action: ContactAction.url,
          actionTarget: 'https://stlukesmarsdenpark.org.au',
          subtitle: null,
        ),
      ];

      for (var i = 0; i < expected.length; i++) {
        final item = staticContactItems[i];
        final exp = expected[i];
        expect(item.label, exp.label, reason: 'index $i label');
        expect(item.value, exp.value, reason: 'index $i value');
        expect(item.action, exp.action, reason: 'index $i action');
        expect(
          item.actionTarget,
          exp.actionTarget,
          reason: 'index $i actionTarget',
        );
        expect(item.subtitle, exp.subtitle, reason: 'index $i subtitle');
      }
    });

    testWidgets('all 8 contact tiles render, including no-action tiles', (
      tester,
    ) async {
      await pumpContactScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.byType(ContactTile), findsNWidgets(8));
      for (final item in staticContactItems) {
        expect(find.text(item.value), findsOneWidget);
        if (item.subtitle != null) {
          expect(find.text(item.subtitle!), findsOneWidget);
        }
      }
    });
  });

  group('REQ-F03-013: tapping call/email/url tiles launches the '
      'corresponding tel:/mailto:/https: URI', () {
    testWidgets('tapping Phone launches tel:0285300173', (tester) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, '(02) 8530 0173');

      expect(fakeLauncher.launchedUrls, ['tel:0285300173']);
    });

    testWidgets('tapping Mobile launches tel:0422724160', (tester) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, '0422 724 160');

      expect(fakeLauncher.launchedUrls, ['tel:0422724160']);
    });

    testWidgets('tapping Email launches mailto:marsdenpark@parracatholic.org', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, 'marsdenpark@parracatholic.org');

      expect(fakeLauncher.launchedUrls, [
        'mailto:marsdenpark@parracatholic.org',
      ]);
    });

    testWidgets('tapping Facebook launches the facebook https: URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, "St Luke's Catholic Parish Marsden Park");

      expect(fakeLauncher.launchedUrls, [
        'https://www.facebook.com/stlukesmarsdenpark/',
      ]);
    });

    testWidgets('tapping Website launches the parish https: URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, 'stlukesmarsdenpark.org.au');

      expect(fakeLauncher.launchedUrls, ['https://stlukesmarsdenpark.org.au']);
    });

    testWidgets('a failed/unavailable launch (e.g. no phone/mail/browser app '
        'installed) does not throw', (tester) async {
      final fakeLauncher = _FakeUrlLauncherService(launchResult: false);
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, '(02) 8530 0173');

      expect(tester.takeException(), isNull);
      expect(fakeLauncher.launchedUrls, ['tel:0285300173']);
    });
  });

  group('REQ-F03-014: Church Address, Postal Address, and Office Hours '
      'tiles are not tappable', () {
    testWidgets('tapping the Church Address tile launches nothing', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, '55a Frontier Ave, Marsden Park NSW 2765');

      expect(fakeLauncher.launchedUrls, isEmpty);
    });

    testWidgets('tapping the Postal Address tile launches nothing', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, 'PO Box 4045, Elara Village');

      expect(fakeLauncher.launchedUrls, isEmpty);
    });

    testWidgets('tapping the Office Hours tile launches nothing', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, 'Monday – Friday · 9:30am – 4:30pm');

      expect(fakeLauncher.launchedUrls, isEmpty);
    });
  });

  group('REQ-F03-015/016: embedded map preview and "Open in Google Maps" '
      'pill both launch/load the parish location', () {
    const expectedMapsUrl =
        'https://maps.google.com/?q=55a+Frontier+Avenue,+Marsden+Park+NSW+2765';
    // The embed URL must be nested inside a real <iframe> in a locally
    // loaded wrapper document (SimpleWebViewScreen's `html`), not loaded
    // directly as the WebView's own page -- Google's `output=embed`
    // endpoint refuses direct top-level loads. See `_mapEmbedHtml`'s doc
    // comment in contact_screen.dart.
    const expectedEmbedSrc =
        'https://maps.google.com/maps?q=55a+Frontier+Avenue,+Marsden+Park+NSW+2765&output=embed';

    testWidgets('renders a live embedded map (in-app WebView), not a '
        'static placeholder', (tester) async {
      await pumpContactScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.byType(SimpleWebViewScreen), findsOneWidget);
      expect(find.byType(WebViewWidget), findsOneWidget);

      final webView = tester.widget<SimpleWebViewScreen>(
        find.byType(SimpleWebViewScreen),
      );
      expect(
        webView.url,
        isNull,
        reason:
            'the embed URL must be nested in an <iframe>, not loaded '
            'directly as the WebView\'s own page',
      );
      expect(webView.html, isNotNull);
      expect(webView.html, contains('<iframe'));
      expect(webView.html, contains(expectedEmbedSrc));
    });

    testWidgets('the embedded map preview does not intercept touches -- it '
        'is wrapped in IgnorePointer, like the PWA\'s own non-interactive '
        '.map-wrap', (tester) async {
      await pumpContactScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      // Flutter's own MaterialApp/Scaffold/Navigator plumbing adds
      // IgnorePointer ancestors of its own (unrelated to ours), so there
      // can legitimately be more than one match here -- assert that at
      // least one of them is the active `ignoring: true` one we added,
      // rather than assuming there's exactly one ancestor (which is what
      // `tester.widget<T>()` -- a `.single` lookup -- would require).
      final ignorePointers = tester.widgetList<IgnorePointer>(
        find.ancestor(
          of: find.byType(SimpleWebViewScreen),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(
        ignorePointers.any((widget) => widget.ignoring),
        isTrue,
        reason:
            'expected an IgnorePointer(ignoring: true) ancestor of the map '
            'preview\'s SimpleWebViewScreen',
      );
    });

    testWidgets('tapping the map-preview card launches the Google Maps URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tester.tap(find.byKey(const Key('contactMapPreviewCard')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeLauncher.launchedUrls, [expectedMapsUrl]);
    });

    testWidgets('tapping "Open in Google Maps" launches the same URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpContactScreen(tester, fakeLauncher: fakeLauncher);

      await tapText(tester, 'Open in Google Maps');

      expect(fakeLauncher.launchedUrls, [expectedMapsUrl]);
    });
  });

  group('REQ-F03-017: ContactItem entity is typed/immutable with a const '
      'constructor', () {
    test('const constructor compiles (this file itself proves it)', () {
      const item = ContactItem(
        icon: 'x',
        label: 'x',
        value: 'x',
        action: ContactAction.none,
      );
      expect(item.label, 'x');
    });
  });
}
