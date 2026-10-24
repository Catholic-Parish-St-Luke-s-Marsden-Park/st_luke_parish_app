import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/masses/data/config/divine_mercy_config.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/rosary_step.dart';
import 'package:st_luke_parish_app/features/masses/presentation/providers/prayer_progress_provider.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/divine_mercy_screen.dart';

import '../../helpers/fake_prayer_progress_store.dart';

class _FakeUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  test('the Chaplet one bead at a time: 64 steps', () {
    // Sign of the Cross, optional opening, Our Father, Hail Mary, Creed;
    // five decades of Eternal Father and ten "For the sake"; Holy God x3;
    // optional closing prayer.
    expect(divineMercySteps, hasLength(64));
    for (var d = 0; d < 5; d++) {
      final base = 5 + d * 11;
      expect(divineMercySteps[base].prayers.single.name, 'The Eternal Father');
      for (var i = 1; i <= 10; i++) {
        final step = divineMercySteps[base + i];
        expect(step.beads.kind, RosaryBeadKind.decadeHailMary);
        expect(
          step.prayers.single.name,
          'For the sake of His sorrowful Passion',
        );
      }
    }
    expect(
      divineMercySteps.sublist(60, 63).map((s) => s.prayers.single.name),
      everyElement('Holy God'),
    );
    expect(divineMercySteps.last.optional, isTrue);
  });

  Future<_FakeUrlLauncher> pump(
    WidgetTester tester, {
    Size size = const Size(800, 2600),
    double scale = 1,
    FakePrayerProgressStore? store,
    DateTime? day,
    bool openCard = true,
  }) async {
    final launcher = _FakeUrlLauncher();
    final progress = store ?? FakePrayerProgressStore();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlLauncherServiceProvider.overrideWithValue(launcher),
          prayerProgressStoreProvider.overrideWith((ref) async => progress),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: DivineMercyScreen(
                now: () => day ?? DateTime(2026, 10, 19),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (openCard) {
      // Below the picture, so scroll down to it on small phones.
      await tester.scrollUntilVisible(
        find.text('Pray the Chaplet'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pray the Chaplet'));
      await tester.pumpAndSettle();
    }
    return launcher;
  }

  Future<void> next(WidgetTester tester, [int times = 1]) async {
    for (var i = 0; i < times; i++) {
      final button = find.text('Next');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Pray the Chaplet starts closed, under the picture', (
    tester,
  ) async {
    await pump(tester, openCard: false);

    expect(find.text(divineMercyImageCaption), findsOneWidget);
    expect(find.text('Pray the Chaplet'), findsOneWidget);
    expect(find.text('Jesus, I trust in You'), findsOneWidget);
    expect(find.text('STEP 1 OF 64'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Pray the Chaplet')).dy,
      greaterThan(tester.getTopLeft(find.text(divineMercyImageCaption)).dy),
    );

    await tester.tap(find.text('Pray the Chaplet'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 1 OF 64'), findsOneWidget);
  });

  testWidgets('one prayer per tap of Next, bead by bead', (tester) async {
    await pump(tester);

    expect(find.widgetWithText(AppBar, 'Divine Mercy Chaplet'), findsOneWidget);
    expect(find.text('STEP 1 OF 64'), findsOneWidget);
    expect(find.text('Sign of the Cross'), findsOneWidget);

    await next(tester, 5);
    expect(find.text('1st Decade'), findsOneWidget);
    expect(find.text('The Eternal Father'), findsOneWidget);

    await next(tester, 3);
    expect(find.text('Bead 3 of 10'), findsOneWidget);
    expect(find.text('For the sake of His sorrowful Passion'), findsOneWidget);
  });

  testWidgets('remembers the bead reached, apart from the Rosary', (
    tester,
  ) async {
    final store = FakePrayerProgressStore()
      ..saved['rosary'] = (DateTime(2026, 10, 19), 30);
    await pump(tester, store: store);
    // The Rosary's saved place does not move the Chaplet.
    expect(find.text('STEP 1 OF 64'), findsOneWidget);
    await next(tester, 12);
    expect(store.saved['divine_mercy_chaplet']?.$2, 12);
    expect(store.saved['rosary']?.$2, 30);

    await tester.pumpWidget(const SizedBox());
    await pump(tester, store: store, day: DateTime(2026, 10, 19, 15));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Continuing at the 1st Decade, where you stopped.'),
      findsOneWidget,
    );
    expect(find.text('STEP 13 OF 64'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pump(tester, store: store, day: DateTime(2026, 10, 20));
    expect(find.text('STEP 1 OF 64'), findsOneWidget);
  });

  testWidgets('ends with Holy God three times and the optional closing', (
    tester,
  ) async {
    await pump(tester);
    await next(tester, 60);
    expect(find.text('Holy God 1 of 3'), findsOneWidget);
    await next(tester, 3);
    expect(find.text('STEP 64 OF 64'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.text('Start again'), findsOneWidget);
  });

  testWidgets('shows the Divine Mercy image with its caption', (tester) async {
    await pump(tester);

    final images = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == divineMercyImage,
    );
    // Large above the card, small on the card, and inside the rosary.
    expect(images, findsNWidgets(3));
    expect(
      tester.widget<Image>(images.first).semanticLabel,
      contains('Divine Mercy'),
    );
    expect(find.text(divineMercyImageCaption), findsOneWidget);
  });

  testWidgets('links to the Divine Mercy page for the longer prayers', (
    tester,
  ) async {
    final launcher = await pump(tester);
    final link = find.text('More prayers at thedivinemercy.org');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    expect(launcher.launchedUrls, [divineMercyPageUrl]);
  });

  for (final scale in const [1.0, 2.0]) {
    testWidgets('no overflow on a small phone at text x$scale', (tester) async {
      await pump(tester, size: const Size(360, 690), scale: scale);
      await next(tester, 6);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -6000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
