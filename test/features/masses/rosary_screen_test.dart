import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/masses/data/config/litany_config.dart';
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
    test('the whole Rosary one bead at a time: 69 steps, each decade on its '
        'Mystery, then the optional prayers', () {
      final set = rosaryMysterySets.last;
      final steps = rosaryStepsFor(set);
      // Crucifix, Our Father, 3 Hail Marys, Glory Be; then five decades of
      // Our Father, 10 Hail Marys and Glory Be/Fatima; then Hail Holy Queen,
      // and the card's optional Memorare and Prayer to St Michael.
      expect(steps, hasLength(69));
      expect(steps.first.beads.kind, RosaryBeadKind.crucifix);
      expect(
        steps.sublist(2, 5).map((s) => s.beads.kind),
        everyElement(RosaryBeadKind.introHailMary),
      );
      for (var d = 0; d < 5; d++) {
        final base = 6 + d * 12;
        expect(steps[base].beads.kind, RosaryBeadKind.decadeOurFather);
        expect(steps[base].mystery, set.mysteries[d]);
        for (var i = 0; i < 10; i++) {
          final hailMary = steps[base + 1 + i];
          expect(hailMary.beads.kind, RosaryBeadKind.decadeHailMary);
          expect(hailMary.beads.decade, d);
          expect(hailMary.beads.bead, i);
          expect(hailMary.mystery, set.mysteries[d]);
        }
        expect(steps[base + 11].prayers.map((p) => p.name), [
          'Glory be to the Father',
          'Fatima Prayer',
        ]);
      }
      expect(steps[66].prayers.first.name, 'Hail, Holy Queen');
      expect(steps[66].optional, isFalse);
      expect(steps[67].prayers.single.name, 'Memorare');
      expect(steps[68].prayers.single.name, 'Prayer to St. Michael');
      expect(steps.skip(67).map((s) => s.optional), everyElement(isTrue));
      for (final step in steps) {
        expect(step.prayers, isNotEmpty, reason: step.instruction);
      }
    });

    Future<void> next(WidgetTester tester, [int times = 1]) async {
      for (var i = 0; i < times; i++) {
        final button = find.text('Next');
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
    }

    testWidgets("opens on step 1 with today's Mysteries named", (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18)); // a Sunday

      expect(find.text('STEP 1 OF 69'), findsOneWidget);
      expect(
        find.text('Today: The Glorious Mysteries, step by step'),
        findsOneWidget,
      );
      expect(find.text("Apostles' Creed"), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Rosary diagram')), findsOneWidget);
    });

    testWidgets('Next sits just under the rosary, above the prayers', (
      tester,
    ) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));

      final nextY = tester.getTopLeft(find.text('Next')).dy;
      expect(
        nextY,
        lessThan(tester.getTopLeft(find.text("Apostles' Creed")).dy),
      );
    });

    testWidgets("each Next prays one bead, with today's Mystery in its "
        'decade', (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 16)); // a Friday

      await next(tester, 2);
      expect(find.text('Hail Mary 1 of 3'), findsOneWidget);
      await next(tester);
      expect(find.text('Hail Mary 2 of 3'), findsOneWidget);

      await next(tester, 3);
      expect(find.text('STEP 7 OF 69'), findsOneWidget);
      expect(find.text('1st Decade'), findsOneWidget);
      expect(find.text('1ST SORROWFUL MYSTERY (1ST DECADE)'), findsOneWidget);
      expect(find.text('The Agony in the Garden'), findsWidgets);

      await next(tester);
      expect(find.text('Hail Mary 1 of 10'), findsOneWidget);
      // Each Hail Mary step shows the whole Mystery, as on the cards.
      expect(find.text('1ST SORROWFUL MYSTERY (1ST DECADE)'), findsOneWidget);
      expect(
        find.text(rosaryMysterySets[2].mysteries.first.verse),
        findsOneWidget,
      );
      expect(find.text('MEDITATE ON'), findsNothing);
      await next(tester, 9);
      expect(find.text('Hail Mary 10 of 10'), findsOneWidget);

      await next(tester, 2);
      expect(find.text('2nd Decade'), findsOneWidget);
      expect(find.text('2ND SORROWFUL MYSTERY (2ND DECADE)'), findsOneWidget);
    });

    testWidgets('Back works, and the last step starts again', (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));

      await next(tester);
      expect(find.text('STEP 2 OF 69'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 OF 69'), findsOneWidget);

      await next(tester, 66);
      expect(find.text('STEP 67 OF 69'), findsOneWidget);
      await next(tester);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Memorare'), findsOneWidget);
      await next(tester);
      expect(find.text('STEP 69 OF 69'), findsOneWidget);
      expect(find.text('Prayer to St. Michael'), findsOneWidget);
      await tester.tap(find.text('Start again'));
      await tester.pumpAndSettle();
      expect(find.text('STEP 1 OF 69'), findsOneWidget);
    });

    testWidgets('nothing moves on its own between taps', (tester) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));
      await next(tester, 7);

      expect(tester.hasRunningAnimations, isFalse);
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
        await next(tester, 7);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -6000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Litany of the Blessed Virgin Mary', () {
    test("follows the card's calls and responses", () {
      expect(litanyLines.first.call, 'Lord, have mercy.');
      expect(litanyLines.where((l) => l.response == 'pray for us.').length, 51);
      expect(
        litanyLines.last.response,
        'R. That we may be made worthy of the promises of Christ.',
      );
      expect(
        litanyClosingPrayer.text,
        endsWith('through Christ Our Lord. Amen.'),
      );
    });

    testWidgets('its own card, closed until opened, under Pray the Rosary', (
      tester,
    ) async {
      await pumpScreen(tester, DateTime(2026, 10, 18));

      expect(find.text(litanyTitle), findsOneWidget);
      expect(find.textContaining('Mother of the Church'), findsNothing);
      expect(
        tester.getTopLeft(find.text(litanyTitle)).dy,
        greaterThan(tester.getTopLeft(find.text('Pray the Rosary')).dy),
      );

      await tester.ensureVisible(find.text(litanyTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(litanyTitle));
      await tester.pumpAndSettle();

      expect(find.textContaining('Mother of the Church'), findsOneWidget);
      expect(find.textContaining('Queen of families'), findsOneWidget);
      expect(find.text(litanyClosingPrayer.text), findsOneWidget);
    });

    testWidgets('no overflow with the litany open at text x2', (tester) async {
      await pumpScreen(
        tester,
        DateTime(2026, 10, 18),
        size: const Size(360, 690),
        scale: 2,
      );
      await tester.dragUntilVisible(
        find.text(litanyTitle),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(litanyTitle));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -8000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group("Pray the Rosary follows the phone's date", () {
    const expectedByWeekday = {
      DateTime.monday: 'The Joyful Mysteries',
      DateTime.tuesday: 'The Sorrowful Mysteries',
      DateTime.wednesday: 'The Glorious Mysteries',
      DateTime.thursday: 'The Luminous Mysteries',
      DateTime.friday: 'The Sorrowful Mysteries',
      DateTime.saturday: 'The Joyful Mysteries',
      DateTime.sunday: 'The Glorious Mysteries',
    };

    test('every day for a year, across month and year ends', () {
      var day = DateTime(2026, 1, 1);
      final end = DateTime(2027, 1, 7);
      var checked = 0;
      while (day.isBefore(end)) {
        expect(
          mysterySetForDay(rosaryMysterySets, day)!.name,
          expectedByWeekday[day.weekday],
          reason: '$day',
        );
        day = DateTime(day.year, day.month, day.day + 1);
        checked++;
      }
      expect(checked, greaterThan(365));
    });

    test('the time of day does not change the set', () {
      for (final hour in [0, 6, 12, 23]) {
        expect(
          mysterySetForDay(
            rosaryMysterySets,
            DateTime(2026, 10, 19, hour, 59), // a Monday
          )!.name,
          'The Joyful Mysteries',
        );
      }
    });

    // One date for each day of the week (19-25 October 2026).
    for (var offset = 0; offset < 7; offset++) {
      final date = DateTime(2026, 10, 19 + offset);
      final setName = expectedByWeekday[date.weekday]!;
      final set = rosaryMysterySets.singleWhere((s) => s.name == setName);

      testWidgets('${date.toIso8601String().substring(0, 10)} '
          '(weekday ${date.weekday}) prays $setName', (tester) async {
        await pumpScreen(tester, date);

        expect(find.text('Today: $setName, step by step'), findsOneWidget);
        // The first decade's step shows that set's first Mystery.
        for (var i = 0; i < 6; i++) {
          final next = find.text('Next');
          await tester.ensureVisible(next);
          await tester.pumpAndSettle();
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        expect(
          find.text('1ST ${set.adjective.toUpperCase()} MYSTERY (1ST DECADE)'),
          findsOneWidget,
        );
        expect(find.text(set.mysteries.first.title), findsWidgets);
        // Its card below is marked as today's.
        expect(find.text("Today's Mysteries"), findsOneWidget);
      });
    }
  });
}
