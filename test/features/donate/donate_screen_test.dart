import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/donate/data/config/donate_config.dart';
import 'package:st_luke_parish_app/features/donate/presentation/screens/donate_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _FakeUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

/// The Donate tab is a native page (parish request, 2026-10-16): the
/// parish's message, card payment via BPOINT in the browser, and EFT
/// details with copy buttons. It no longer embeds the website.
void main() {
  late _FakeUrlLauncher launcher;
  late List<String?> clipboard;

  setUp(() {
    clipboard = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard.add((call.arguments as Map)['text'] as String?);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpDonate(
    WidgetTester tester, {
    Size size = const Size(800, 3000),
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    launcher = _FakeUrlLauncher();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [urlLauncherServiceProvider.overrideWithValue(launcher)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: const Scaffold(body: DonateScreen()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("shows the parish's message, signed by the parish priest, and "
      'what a gift supports', (tester) async {
    await pumpDonate(tester);

    expect(find.text(DonateConfig.heading), findsOneWidget);

    // The letter is a pull-down headed "Message from Fr Gayan".
    expect(find.text('Message from Fr Gayan'), findsOneWidget);
    expect(find.text(DonateConfig.letter.last), findsNothing);
    expect(find.text('Fr Gayan Thamel'), findsNothing);
    await tester.tap(find.text('Message from Fr Gayan'));
    await tester.pumpAndSettle();
    for (final paragraph in DonateConfig.letter) {
      expect(find.text(paragraph), findsOneWidget);
    }
    expect(find.text('Fr Gayan Thamel'), findsOneWidget);
    await tester.tap(find.text('Message from Fr Gayan'));
    await tester.pumpAndSettle();
    expect(DonateConfig.givingAreas.map((a) => a.title), [
      'Personnel & Staffing',
      'Facilities & Operations',
      'Sacramental & Altar Supplies',
      'Faith Formation & Education',
      'Capital Improvements (Building Fund)',
    ]);
    // "Your gift supports" is itself a pull-down: closed, no areas show.
    expect(find.text('Your gift supports'), findsOneWidget);
    expect(find.text(DonateConfig.givingAreas.first.title), findsNothing);
    expect(find.text(DonateConfig.alsoPayFor), findsNothing);
    await tester.ensureVisible(find.text('Your gift supports'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your gift supports'));
    await tester.pumpAndSettle();

    // Open, only the area titles show; each pulls down its description.
    for (final area in DonateConfig.givingAreas) {
      expect(find.text(area.title), findsOneWidget, reason: area.title);
      expect(find.text(area.description), findsNothing, reason: area.title);
    }
    for (final area in DonateConfig.givingAreas) {
      final title = find.text(area.title);
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(find.text(area.description), findsOneWidget, reason: area.title);
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(find.text(area.description), findsNothing, reason: area.title);
    }
    expect(find.text(DonateConfig.alsoPayFor), findsOneWidget);
    // No permanent church yet: the Building Fund saves towards one.
    expect(
      DonateConfig.givingAreas.last.description,
      contains("first permanent church"),
    );
  });

  testWidgets('no longer embeds the website in a WebView', (tester) async {
    await pumpDonate(tester);

    expect(find.byType(WebViewWidget), findsNothing);
  });

  testWidgets('Donate by Card opens BPOINT in the browser', (tester) async {
    await pumpDonate(tester);

    final button = find.text('Donate by Card');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(button);

    expect(launcher.launchedUrls, [
      'https://www.bpoint.com.au/pay/CATHOLICPARISH1',
    ]);
  });

  testWidgets('shows the EFT details exactly as on the parish website', (
    tester,
  ) async {
    await pumpDonate(tester);

    expect(find.text("Marsden Park St Luke's Parish"), findsOneWidget);
    expect(find.text('067 950'), findsOneWidget);
    expect(find.text('100005720'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
  });

  testWidgets('each EFT detail can be copied, with a confirmation', (
    tester,
  ) async {
    await pumpDonate(tester);

    for (final (label, value) in [
      ('Account name', "Marsden Park St Luke's Parish"),
      ('BSB', '067 950'),
      ('Account number', '100005720'),
    ]) {
      final copy = find.byTooltip('Copy $label');
      await tester.ensureVisible(copy);
      await tester.pumpAndSettle();
      final button = find.ancestor(of: copy, matching: find.byType(IconButton));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      await tester.tap(copy);
      await tester.pump();
      // Let the snack bar animate in.
      await tester.pump(const Duration(milliseconds: 500));
      expect(clipboard.last, value, reason: label);
      expect(find.text('$label copied'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
    // The reference is an instruction, not something to copy.
    expect(find.byTooltip('Copy Reference'), findsNothing);
  });

  testWidgets('shows the refund policy with the parish email', (tester) async {
    await pumpDonate(tester);

    expect(find.text(DonateConfig.refundPolicy), findsOneWidget);
    expect(
      DonateConfig.refundPolicy,
      contains('marsdenpark@parracatholic.org'),
    );
  });

  for (final size in const [Size(360, 690), Size(390, 844)]) {
    for (final scale in const [1.0, 1.5, 2.0]) {
      testWidgets('no overflow at $size, text x$scale', (tester) async {
        await pumpDonate(
          tester,
          size: size,
          textScaler: TextScaler.linear(scale),
        );
        expect(tester.takeException(), isNull);
        // Open the message and every area so the longest layout is checked.
        final message = find.text(DonateConfig.messageTitle);
        await tester.scrollUntilVisible(
          message,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(message);
        await tester.pumpAndSettle();
        final gifts = find.text('Your gift supports');
        await tester.scrollUntilVisible(
          gifts,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(gifts);
        await tester.pumpAndSettle();
        for (final area in DonateConfig.givingAreas) {
          final title = find.text(area.title);
          // The list builds lazily, so scroll each title into view first.
          await tester.scrollUntilVisible(
            title,
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(title);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -6000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
