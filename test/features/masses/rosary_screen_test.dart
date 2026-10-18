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

  testWidgets("today's mysteries show their pictures", (tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: RosaryScreen(now: () => DateTime(2026, 10, 18))),
    );
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

  testWidgets("today's set comes first, already open, marked Today", (
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
    expect(find.text('The Agony in the Garden'), findsOneWidget);
    expect(find.text('1ST SORROWFUL MYSTERY (1ST DECADE)'), findsOneWidget);
    expect(find.text('5TH SORROWFUL MYSTERY (5TH DECADE)'), findsOneWidget);
    // Other sets start closed.
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

  group('How to Pray the Rosary', () {
    test("the card's ten steps, each with its prayers", () {
      expect(rosarySteps, hasLength(10));
      for (final step in rosarySteps) {
        expect(step.prayers, isNotEmpty, reason: step.instruction);
      }
      expect(rosarySteps.first.beads, RosaryBeadGroup.crucifix);
      expect(rosarySteps[5].beads, RosaryBeadGroup.firstDecade);
      expect(rosarySteps.last.prayers.first.name, 'Hail, Holy Queen');
    });

    Future<void> openHowTo(WidgetTester tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));
      expect(find.text('How to Pray the Rosary'), findsOneWidget);
      expect(find.text('STEP 1 OF 10'), findsNothing);
      await tester.tap(find.text('How to Pray the Rosary'));
      await tester.pumpAndSettle();
    }

    testWidgets('opens on step 1 with the rosary diagram and its prayers', (
      tester,
    ) async {
      await openHowTo(tester);

      expect(find.text('STEP 1 OF 10'), findsOneWidget);
      expect(find.text(rosarySteps.first.instruction), findsOneWidget);
      expect(find.text("Apostles' Creed"), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Rosary diagram')), findsOneWidget);
    });

    testWidgets('Next and Back move through the steps; the last step '
        'starts again', (tester) async {
      await openHowTo(tester);

      Future<void> tap(String label) async {
        final button = find.text(label);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      await tap('Next');
      expect(find.text('STEP 2 OF 10'), findsOneWidget);
      await tap('Back');
      expect(find.text('STEP 1 OF 10'), findsOneWidget);

      for (var i = 0; i < 4; i++) {
        await tap('Next');
      }
      // Step 5 announces the First Mystery and names today's set.
      expect(find.text('STEP 5 OF 10'), findsOneWidget);
      expect(
        find.text("Today's Mysteries: The Glorious Mysteries"),
        findsOneWidget,
      );

      for (var i = 0; i < 5; i++) {
        await tap('Next');
      }
      expect(find.text('STEP 10 OF 10'), findsOneWidget);
      await tap('Start again');
      expect(find.text('STEP 1 OF 10'), findsOneWidget);
    });

    for (final scale in const [1.0, 2.0]) {
      testWidgets('no overflow with the steps open at text x$scale', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          DateTime(2026, 10, 18),
          size: const Size(360, 690),
          scale: scale,
        );
        await tester.tap(find.text('How to Pray the Rosary'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
