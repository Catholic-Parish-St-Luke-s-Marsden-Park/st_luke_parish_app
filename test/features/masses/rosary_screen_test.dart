import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/masses/data/config/rosary_how_to_config.dart';
import 'package:st_luke_parish_app/features/masses/data/config/rosary_mysteries_config.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/rosary_step.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/rosary_mystery.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/rosary_screen.dart';

void main() {
  test('four sets of five mysteries, covering every day of the week once', () {
    expect(rosaryMysterySets.map((s) => s.name), [
      'The Joyful Mysteries',
      'The Luminous Mysteries',
      'The Sorrowful Mysteries',
      'The Glorious Mysteries',
    ]);
    for (final set in rosaryMysterySets) {
      expect(set.mysteries, hasLength(5), reason: set.name);
    }
    final days = rosaryMysterySets.expand((s) => s.weekdays).toList()..sort();
    expect(days, [1, 2, 3, 4, 5, 6, 7]);
  });

  test('every mystery has its own picture from the card', () {
    final assets = [
      for (final set in rosaryMysterySets)
        for (final mystery in set.mysteries) mystery.imageAsset,
    ];
    expect(assets.toSet(), hasLength(20));
    for (final asset in assets) {
      expect(File(asset).existsSync(), isTrue, reason: asset);
    }
  });

  testWidgets('each mystery shows its picture', (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: RosaryScreen(now: () => DateTime(2026, 10, 18))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pray the Rosary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The Glorious Mysteries'));
    await tester.pumpAndSettle();

    final shown = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName)
        .toList();
    expect(shown, [
      for (final mystery in rosaryMysterySets.last.mysteries)
        mystery.imageAsset,
    ]);
  });

  test("today's set follows the card's days", () {
    // 2026-10-17 is a Saturday, 2026-10-15 a Thursday, 2026-10-18 a Sunday.
    String today(DateTime d) => mysterySetForDay(rosaryMysterySets, d)!.name;
    expect(today(DateTime(2026, 10, 17)), 'The Joyful Mysteries');
    expect(today(DateTime(2026, 10, 15)), 'The Luminous Mysteries');
    expect(today(DateTime(2026, 10, 16)), 'The Sorrowful Mysteries');
    expect(today(DateTime(2026, 10, 18)), 'The Glorious Mysteries');
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    DateTime day, {
    Size size = const Size(800, 2600),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: RosaryScreen(now: () => day),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("today's set comes first among the Mysteries, marked Today", (
    tester,
  ) async {
    await pumpScreen(tester, DateTime(2026, 10, 16)); // a Friday

    expect(find.widgetWithText(AppBar, 'The Rosary'), findsOneWidget);
    final tops = [
      for (final name in [
        'The Sorrowful Mysteries',
        'The Joyful Mysteries',
        'The Luminous Mysteries',
        'The Glorious Mysteries',
      ])
        tester.getTopLeft(find.text(name)).dy,
    ];
    expect(tops, orderedEquals(List.of(tops)..sort()));
    expect(find.text("Today's Mysteries"), findsOneWidget);
    // The sets start closed; opening one shows its decade labels.
    expect(find.text('1ST SORROWFUL MYSTERY (1ST DECADE)'), findsNothing);
    await tester.tap(find.text('The Sorrowful Mysteries'));
    await tester.pumpAndSettle();
    expect(find.text('1ST SORROWFUL MYSTERY (1ST DECADE)'), findsOneWidget);
    expect(find.text('5TH SORROWFUL MYSTERY (5TH DECADE)'), findsOneWidget);
    expect(find.text('The Annunciation'), findsNothing);
  });

  testWidgets('opening another set shows its five mysteries', (tester) async {
    await pumpScreen(tester, DateTime(2026, 10, 16));

    await tester.tap(find.text('The Glorious Mysteries'));
    await tester.pumpAndSettle();

    for (final mystery in rosaryMysterySets.last.mysteries) {
      expect(find.text(mystery.title), findsOneWidget, reason: mystery.title);
      expect(find.text(mystery.reference), findsOneWidget);
    }
  });

  testWidgets('credits the Rosary card it comes from', (tester) async {
    await pumpScreen(tester, DateTime(2026, 10, 16));

    await tester.drag(find.byType(ListView), const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(find.text(rosaryMysteriesSource), findsOneWidget);
    expect(rosaryMysteriesSource, contains("Mary's Rosary Chain"));
  });

  for (final scale in const [1.0, 2.0]) {
    testWidgets('no overflow on a small phone at text x$scale', (tester) async {
      await pumpScreen(
        tester,
        DateTime(2026, 10, 16),
        size: const Size(360, 690),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -8000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  group('Pray the Rosary', () {
    test('the whole Rosary in 20 steps, with each decade on its Mystery', () {
      final set = rosaryMysterySets.last;
      final steps = rosaryStepsFor(set);
      expect(steps, hasLength(20));
      expect(steps.first.beads.kind, RosaryBeadKind.crucifix);
      expect(steps.last.prayers.first.name, 'Hail, Holy Queen');
      for (var d = 0; d < 5; d++) {
        final announce = steps[4 + d * 3];
        final decade = steps[5 + d * 3];
        expect(announce.beads.kind, RosaryBeadKind.decadeOurFather);
        expect(announce.mystery, set.mysteries[d]);
        expect(decade.beads.kind, RosaryBeadKind.decadeHailMarys);
        expect(decade.beads.decade, d);
        expect(steps[6 + d * 3].prayers.map((p) => p.name), [
          'Glory be to the Father',
          'Fatima Prayer',
        ]);
      }
      for (final step in steps) {
        expect(step.prayers, isNotEmpty, reason: step.instruction);
      }
    });

    Future<void> next(WidgetTester tester, [int times = 1]) async {
      for (var i = 0; i < times; i++) {
        final button = find.text('Next');
        // Each step changes the page's length, so search down from the top.
        await tester.drag(find.byType(ListView), const Offset(0, 8000));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          button,
          find.byType(ListView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
    }

    testWidgets("opens on step 1 with today's Mysteries named", (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18)); // a Sunday

      expect(find.text('STEP 1 OF 20'), findsOneWidget);
      expect(
        find.text('Today: The Glorious Mysteries, step by step'),
        findsOneWidget,
      );
      expect(find.text("Apostles' Creed"), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Rosary diagram')), findsOneWidget);
    });

    testWidgets("today's Mysteries appear in their decades", (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 16)); // a Friday

      await next(tester, 4);
      expect(find.text('STEP 5 OF 20'), findsOneWidget);
      expect(find.text('1st Decade'), findsOneWidget);
      expect(find.text('1ST SORROWFUL MYSTERY'), findsOneWidget);
      expect(find.text('The Agony in the Garden'), findsWidgets);

      await next(tester);
      expect(find.text('MEDITATE ON'), findsOneWidget);
      expect(find.text('Hail Mary'), findsOneWidget);

      await next(tester, 2);
      expect(find.text('2nd Decade'), findsOneWidget);
      expect(find.text('2ND SORROWFUL MYSTERY'), findsOneWidget);
    });

    testWidgets('Back works, and the last step starts again', (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));

      await next(tester);
      expect(find.text('STEP 2 OF 20'), findsOneWidget);
      final back = find.text('Back');
      await tester.ensureVisible(back);
      await tester.pumpAndSettle();
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 OF 20'), findsOneWidget);

      await next(tester, 19);
      expect(find.text('STEP 20 OF 20'), findsOneWidget);
      final again = find.text('Start again');
      await tester.ensureVisible(again);
      await tester.pumpAndSettle();
      await tester.tap(again);
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 OF 20'), findsOneWidget);
    });

    for (final scale in const [1.0, 2.0]) {
      testWidgets('no overflow on a Mystery step at text x$scale', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          DateTime(2026, 10, 18),
          size: const Size(360, 690),
          scale: scale,
        );
        await next(tester, 4);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -6000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
