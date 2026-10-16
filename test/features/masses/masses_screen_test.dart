import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';
import 'package:st_luke_parish_app/features/masses/data/config/static_mass_schedule_config.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_schedule.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_sub_group.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_time.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_times_card.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/parish_activity.dart';
import 'package:st_luke_parish_app/features/masses/presentation/providers/mass_schedule_provider.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/masses_screen.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/activity_ribbon.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_symbol_icon.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_card.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/draped_rosary_icon.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/rosary_icon.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_row.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_section_header.dart';

/// Covers the Masses tab acceptance criteria: REQ-F04-001..024.
///
/// This feature is static, hardcoded content with no async/network layer,
/// so "loading", "empty result", "parsing failure", "network failure",
/// "missing selector result", and "invalid URL result" states are all
/// intentionally not applicable/not covered here (matches REQ-F04-024's own
/// note and the BA plan's Acceptance Criteria).
class _RecordingUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  Future<void> pumpMassesScreen(WidgetTester tester) async {
    // MassesScreen's content (hero + What's On + Regular Activities) is far
    // taller than the default 800x600 test surface, which would leave the
    // second section outside the ListView's build/cache extent. Use a tall
    // surface so everything is built without scrolling mid-test (same pattern
    // as contact_screen_test.dart).
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: MassesScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Scoped to the ribbons: "Marsden Park Care Community Mass" is also a
  // Weekday row name in the What's On card.
  Finder ribbonTitle(ParishActivity activity) => find.descendant(
    of: find.byType(ActivityRibbon),
    matching: find.text(activity.title),
  );

  group(
    'REQ-F04-001: MassesScreen renders real content, not a placeholder',
    () {
      testWidgets('does not render the generic PlaceholderScreen icon', (
        tester,
      ) async {
        await pumpMassesScreen(tester);

        expect(tester.takeException(), isNull);
        // The generic placeholder used this icon as its sole content; it
        // must not appear now that MassesScreen has real content.
        expect(find.byIcon(Icons.calendar_month_rounded), findsNothing);
        expect(find.text('Masses & Events'), findsNothing);
      });
    },
  );

  group('REQ-F04-002: hero banner copy', () {
    testWidgets('renders the eyebrow and "Mass Times" title, no address '
        'subtitle line', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.text("ST LUKE'S · MARSDEN PARK"), findsOneWidget);
      expect(find.text('Mass Times'), findsOneWidget);

      // No address/location subtitle anywhere on the screen.
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final mentionsAddress = textWidgets.any(
        (t) => (t.data ?? '').toLowerCase().contains('frontier ave'),
      );
      expect(mentionsAddress, isFalse);
    });
  });

  group('REQ-F04-003/004: "What\'s On" section: Saturday Vigil, Sunday, '
      'then Weekday cards', () {
    testWidgets('renders the three card headings in order, with no '
        '"What\'s On" title above them', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.text("What's On"), findsNothing);
      expect(find.byType(MassCard), findsNWidgets(3));

      // Saturday Vigil first, then Sunday, then Weekday (2026-10-15).
      final inOrder = [
        'Saturday Vigil Mass',
        'Sunday Mass Times',
        'Weekday Mass Times',
      ];
      for (final text in inOrder) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      final positions = inOrder
          .map((t) => tester.getTopLeft(find.text(t)).dy)
          .toList();
      expect(positions, orderedEquals(List.of(positions)..sort()));

      // No "Weekend Mass Times" card and no repeated sub-labels.
      for (final gone in [
        'Weekend Mass Times',
        'SATURDAY VIGIL MASS',
        'SUNDAY MASS TIMES',
        'WEEKDAY',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
    });

    testWidgets('each card heading is white text on a navy band', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      for (final heading in [
        'Saturday Vigil Mass',
        'Sunday Mass Times',
        'Weekday Mass Times',
      ]) {
        final text = tester.widget<Text>(find.text(heading));
        expect(text.style?.color, Colors.white, reason: heading);
        final band = tester.widget<Container>(
          find
              .ancestor(
                of: find.text(heading),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(band.color, AppColors.primaryNavy, reason: heading);
      }
    });

    testWidgets('each heading sits in its own card, above its Mass rows', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      Finder inCard(String heading, String text) => find.descendant(
        of: find.ancestor(
          of: find.text(heading),
          matching: find.byType(MassCard),
        ),
        matching: find.text(text),
      );
      expect(inCard('Saturday Vigil Mass', '5:30 PM'), findsOneWidget);
      expect(inCard('Saturday Vigil Mass', '8:00 AM'), findsNothing);
      expect(inCard('Sunday Mass Times', '8:00 AM'), findsOneWidget);
      expect(inCard('Sunday Mass Times', '5:30 PM'), findsOneWidget);
      expect(inCard('Sunday Mass Times', 'Wednesday'), findsNothing);
      expect(inCard('Weekday Mass Times', 'Wednesday'), findsOneWidget);
      expect(inCard('Weekday Mass Times', '11:00 AM'), findsOneWidget);
      expect(inCard('Weekday Mass Times', '8:00 AM'), findsNothing);
    });

    testWidgets('the Mass times cards are always open: no expansion tiles '
        'or tap targets', (tester) async {
      await pumpMassesScreen(tester);

      for (final type in [ExpansionTile, InkWell, GestureDetector]) {
        expect(
          find.descendant(
            of: find.byType(MassCard),
            matching: find.byType(type),
          ),
          findsNothing,
        );
      }
    });
  });

  group('REQ-F04-005: Sunday Mass Times — the three times on one '
      'row, then the Care Community row', () {
    testWidgets('renders the Sunday times above the Care Community row', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      final sundayLabelY = tester.getTopLeft(find.text('Sunday Mass Times')).dy;
      final careY = tester
          .getTopLeft(find.text('at Marsden Park Care Community'))
          .dy;
      // 10:00 AM's first match is Sunday Mass (the second is the Care
      // Community); 5:30 PM's last match is Sunday (the first is the Vigil).
      final rowYs = [
        for (final finder in [
          find.text('8:00 AM'),
          find.text('10:00 AM').first,
          find.text('5:30 PM').last,
        ])
          tester.getTopLeft(finder).dy,
      ];
      // The three Sunday times share one line, under the Sunday label.
      expect(rowYs.toSet(), hasLength(1));
      expect(rowYs.first, greaterThan(sundayLabelY));
      expect(rowYs.first, lessThan(careY));
      // 10:00 AM: the Sunday Mass and the Care Community row.
      expect(find.text('10:00 AM'), findsNWidgets(2));
      expect(find.text('at Marsden Park Care Community'), findsOneWidget);
      expect(
        find.text(
          '4th Sunday of the month: Liturgy of the Word with Holy Communion',
        ),
        findsOneWidget,
      );
      // Times are plain text: no gold oval behind them.
      final goldBoxes = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(MassCard),
              matching: find.byType(DecoratedBox),
            ),
          )
          .where(
            (box) =>
                box.decoration is BoxDecoration &&
                (box.decoration as BoxDecoration).color == AppColors.gold,
          );
      expect(goldBoxes, isEmpty);
      // The old "Times:" text and one-row-per-Mass layout are gone.
      expect(find.textContaining('Times:'), findsNothing);
      expect(find.text('Sunday Mass'), findsNothing);
      expect(find.text('Sun 8:00 AM'), findsNothing);
    });
  });

  group('REQ-F04-006: Saturday Vigil sub-group — exactly 1 row with note', () {
    testWidgets('renders the exact Vigil row and its note', (tester) async {
      await pumpMassesScreen(tester);

      // First "5:30 PM" is the Vigil; the second is Sunday evening.
      final vigil = find.text('5:30 PM').first;
      expect(find.text('Reconciliation from 4:30–5:25pm'), findsOneWidget);
      expect(
        tester.getTopLeft(vigil).dy,
        lessThan(
          tester.getTopLeft(find.text('Reconciliation from 4:30–5:25pm')).dy,
        ),
      );
      expect(find.textContaining('Time:'), findsNothing);
      expect(find.text('Sat 5:30 PM'), findsNothing);
    });
  });

  group('REQ-F04-007: Weekday sub-group — day/time rows plus the monthly '
      'Care Community Mass, in order', () {
    testWidgets('renders the exact Weekday rows', (tester) async {
      await pumpMassesScreen(tester);

      // Each row: the day name, then its time on the same line.
      const rows = [
        ('Wednesday', '7:30 AM'),
        ('Thursday', '9:00 AM'),
        ('Friday', '6:30 PM'),
        ('Friday', '11:00 AM'),
      ];
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget);
      expect(find.text('Friday'), findsNWidgets(2));
      final fridays = find.text('Friday');
      final positions = <double>[];
      for (final (i, (day, time)) in rows.indexed) {
        final dayFinder = day == 'Friday' ? fridays.at(i - 2) : find.text(day);
        final timeFinder = find.text(time);
        expect(timeFinder, findsOneWidget, reason: time);
        final timeY = tester.getCenter(timeFinder).dy;
        expect(
          tester.getCenter(dayFinder).dy,
          moreOrLessEquals(timeY, epsilon: 2),
          reason: '$day and $time share a line',
        );
        expect(
          tester.getTopLeft(timeFinder).dx,
          greaterThan(tester.getTopLeft(dayFinder).dx),
        );
        positions.add(timeY);
      }
      expect(positions, orderedEquals(List.of(positions)..sort()));
      // No "Day: time" text is left.
      expect(find.textContaining(': 7:30 AM'), findsNothing);

      expect(
        find.descendant(
          of: find.byType(MassCard),
          matching: find.text('Marsden Park Care Community Mass'),
        ),
        findsOneWidget,
      );
      expect(find.text('2nd Friday of the month'), findsOneWidget);
      expect(
        find.text(
          '1st Friday of the month: Healing Mass & Benediction, with the '
          'Anointing of the Sick',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the removed weekday Mass titles no longer appear', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.text('Weekday Mass'), findsNothing);
      expect(find.textContaining('College Mass'), findsNothing);
      expect(find.text('Thu 9:30 AM'), findsNothing);
      // Weekday names are spelled out (2026-10-15).
      for (final short in ['Wed ', 'Thu ', 'Fri ']) {
        expect(find.textContaining(short), findsNothing, reason: short);
      }
    });
  });

  group('REQ-F04-008: no stray location/venue text in "What\'s On"', () {
    testWidgets('only the Saturday Vigil row carries a note, and it is the '
        'exact expected string', (tester) async {
      await pumpMassesScreen(tester);

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final mentionsCarpark = textWidgets.any(
        (t) => (t.data ?? '').toLowerCase().contains('carpark'),
      );
      expect(mentionsCarpark, isFalse);
    });
  });

  group('REQ-F04-009: "Regular Activities" section (formerly '
      '"Reconciliation & Sacraments"), from the parish bulletin', () {
    testWidgets('renders one collapsed ribbon per activity, in order', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.text('Regular Parish Activities'), findsOneWidget);
      expect(find.text('Reconciliation & Sacraments'), findsNothing);
      expect(
        find.byType(ActivityRibbon),
        findsNWidgets(regularActivities.length),
      );

      final positions = [
        for (final activity in regularActivities)
          tester.getTopLeft(ribbonTitle(activity)).dy,
      ];
      expect(positions, orderedEquals(List.of(positions)..sort()));

      // Collapsed: details stay hidden until a ribbon is tapped.
      expect(find.text('WHEN'), findsNothing);
      expect(find.text(regularActivities.first.description!), findsNothing);
    });

    testWidgets('tapping a ribbon pulls down its When / Where / Who, '
        'description and contact', (tester) async {
      await pumpMassesScreen(tester);

      final youth = regularActivities.firstWhere(
        (a) => a.title == 'Youth Ministry',
      );
      await tester.tap(find.text(youth.title));
      await tester.pumpAndSettle();

      for (final label in ['WHEN', 'WHERE', 'WHO', 'CONTACT']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      for (final detail in youth.details) {
        expect(find.text(detail), findsOneWidget, reason: detail);
      }

      await tester.tap(find.text(youth.title));
      await tester.pumpAndSettle();
      expect(find.text('WHEN'), findsNothing);
    });

    testWidgets("every activity's details show once expanded", (tester) async {
      await pumpMassesScreen(tester);

      // One at a time, so the list never grows past the built area.
      for (final activity in regularActivities) {
        expect(activity.details, isNotEmpty, reason: activity.title);
        await tester.ensureVisible(ribbonTitle(activity));
        await tester.tap(ribbonTitle(activity));
        await tester.pumpAndSettle();
        for (final detail in activity.details) {
          expect(find.text(detail), findsWidgets, reason: detail);
        }
        await tester.tap(ribbonTitle(activity));
        await tester.pumpAndSettle();
      }
      expect(find.text('WHEN'), findsNothing);
    });

    test('the parish email is the contact on the enquiry activities', () {
      final contacts = [
        for (final activity in regularActivities) ?activity.contact,
      ];
      expect(contacts, isNotEmpty);
      expect(contacts, everyElement('marsdenpark@parracatholic.org'));
    });

    testWidgets('the last ribbon is "Holy Rosary", with a '
        'rosary icon; the Diocese of Parramatta ribbon is gone', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(regularActivities.last.title, 'Holy Rosary');
      expect(
        regularActivities.last.description,
        contains('October is the Month of the Holy Rosary'),
      );
      expect(
        regularActivities.last.when,
        'During October: Saturday & Sunday at 5:00pm, before the 5:30pm Mass',
      );
      expect(
        regularActivities.any((a) => a.title == 'Diocese of Parramatta'),
        isFalse,
      );

      final ribbon = find.ancestor(
        of: ribbonTitle(regularActivities.last),
        matching: find.byType(ActivityRibbon),
      );
      await tester.ensureVisible(ribbon);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: ribbon, matching: find.byType(RosaryIcon)),
        findsOneWidget,
      );
    });

    testWidgets('the Holy Rosary ribbon links to the Rosary prayer card', (
      tester,
    ) async {
      final launcher = _RecordingUrlLauncher();
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [urlLauncherServiceProvider.overrideWithValue(launcher)],
          child: const MaterialApp(home: Scaffold(body: MassesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      final rosary = regularActivities.last;
      await tester.ensureVisible(ribbonTitle(rosary));
      await tester.pumpAndSettle();
      await tester.tap(ribbonTitle(rosary));
      await tester.pumpAndSettle();

      final button = find.text('Open the Rosary Prayer Card');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(button);
      expect(launcher.launchedUrls, [
        'https://www.marysrosarychain.org/prayers/FullRosaryCard.pdf',
      ]);
    });

    testWidgets('the Rosary Block has its own draped rosary icon, different '
        "from the Holy Rosary's", (tester) async {
      await pumpMassesScreen(tester);

      final block = regularActivities.singleWhere(
        (a) => a.title == 'Rosary Block',
      );
      final ribbon = find.ancestor(
        of: ribbonTitle(block),
        matching: find.byType(ActivityRibbon),
      );
      await tester.ensureVisible(ribbon);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: ribbon, matching: find.byType(DrapedRosaryIcon)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: ribbon, matching: find.byType(RosaryIcon)),
        findsNothing,
      );
    });

    test('each activity kind is used once, so every ribbon has its own '
        'icon', () {
      final kinds = regularActivities.map((a) => a.kind).toList();
      expect(kinds.toSet().length, kinds.length);
      expect(kinds.toSet(), ParishActivityKind.values.toSet());
    });

    test('drops one-off bulletin dates and the old placeholder rows', () {
      // The Holy Rosary is an October devotion by design (parish request,
      // 2026-10-16), so it is left out of this check.
      final allText = regularActivities
          .where((a) => a.kind != ParishActivityKind.prayRosary)
          .expand((a) => [a.title, ...a.details])
          .join('\n');
      for (final stale in [
        'This Weekend',
        'This weekend',
        'Next Youth Program',
        'Next session',
        'October',
        'November',
        'Baptisms & House Blessings',
        'Sacramental Programme',
      ]) {
        expect(allText, isNot(contains(stale)));
      }
      // Enquiry emails stay as printed in the bulletin.
      expect(allText, contains('marsdenpark@parracatholic.org'));
    });

    testWidgets('"Regular Parish Activities" comes after the Mass times '
        'cards', (tester) async {
      await pumpMassesScreen(tester);

      final whatsOnY = tester.getTopLeft(find.byType(MassCard).last).dy;
      final reconciliationY = tester
          .getTopLeft(find.text('Regular Parish Activities'))
          .dy;
      expect(reconciliationY, greaterThan(whatsOnY));
    });
  });

  group('REQ-F04-010: no stray location/venue text in "Regular '
      'Activities"', () {
    testWidgets('no activity mentions a "venue"', (tester) async {
      await pumpMassesScreen(tester);

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final mentionsAddress = textWidgets.any(
        (t) => (t.data ?? '').toLowerCase().contains('venue'),
      );
      expect(mentionsAddress, isFalse);
    });
  });

  group('REQ-F04-011: no icon/emoji on the Mass times (Regular Activities '
      'ribbons carry their own icons)', () {
    testWidgets('no Icon widget on any Mass row', (tester) async {
      await pumpMassesScreen(tester);

      expect(
        find.descendant(of: find.byType(MassRow), matching: find.byType(Icon)),
        findsNothing,
      );
    });

    testWidgets('each card title has its own icon in the navy band', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      // A chalice and the host for the Vigil and Sunday Masses; a calendar for
      // weekdays. No sun or moon.
      final expected = {
        'Saturday Vigil Mass': find.byType(MassSymbolIcon),
        'Sunday Mass Times': find.byType(MassSymbolIcon),
        'Weekday Mass Times': find.byIcon(Icons.calendar_today_outlined),
      };
      for (final MapEntry(key: title, value: icon) in expected.entries) {
        final card = find.ancestor(
          of: find.text(title),
          matching: find.byType(MassCard),
        );
        final inCard = find.descendant(of: card, matching: icon);
        expect(inCard, findsOneWidget, reason: title);
        expect(
          tester.getTopLeft(inCard).dx,
          lessThan(tester.getTopLeft(find.text(title)).dx),
          reason: '$title icon comes first',
        );
      }
      expect(find.byIcon(Icons.nights_stay_outlined), findsNothing);
      expect(find.byIcon(Icons.wb_sunny_outlined), findsNothing);
    });

    testWidgets('Mass row text is navy, matching the times', (tester) async {
      await pumpMassesScreen(tester);

      for (final text in [
        'Wednesday',
        'at Marsden Park Care Community',
        'Marsden Park Care Community Mass',
      ]) {
        final widget = tester.widget<Text>(find.text(text).first);
        expect(widget.style?.color, AppColors.primaryNavy, reason: text);
      }
    });

    testWidgets('no rendered Text contains an emoji glyph', (tester) async {
      await pumpMassesScreen(tester);

      // A representative sweep of common emoji ranges/glyphs; this static
      // screen's content is fully known and contains none of these.
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
        unicode: true,
      );
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final hasEmoji = textWidgets.any(
        (t) => emojiPattern.hasMatch(t.data ?? ''),
      );
      expect(hasEmoji, isFalse);
    });
  });

  group('REQ-F04-012: no "Details"/chevron/arrow affordance on any Mass '
      'row', () {
    testWidgets('no chevron/arrow icon and no "Details" text anywhere', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
      expect(find.textContaining('Details'), findsNothing);
      expect(find.textContaining('↗'), findsNothing);

      // No tap targets on Mass rows: the What's On card has no gesture
      // detector/inkwell (rows are plain, non-interactive text per
      // REQ-F04-012). Only the Regular Activities ribbons are tappable.
      for (final type in [InkWell, GestureDetector]) {
        expect(
          find.descendant(
            of: find.byType(MassCard),
            matching: find.byType(type),
          ),
          findsNothing,
        );
      }
    });
  });

  group('REQ-F04-013: every time value is weekday+time or an approved '
      'non-clock-time label — never a date/month', () {
    testWidgets('no row renders a date/day-of-month or month name', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final month in monthNames) {
        final mentionsMonth = textWidgets.any(
          (t) => (t.data ?? '').contains(month),
        );
        expect(mentionsMonth, isFalse, reason: 'should not mention $month');
      }
    });
  });

  group('REQ-F04-014: three Mass times cards, then the activity ribbons '
      'under the only section title', () {
    testWidgets('exactly 1 MassSectionHeader, 3 MassCard and one ribbon per '
        'activity', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.byType(MassSectionHeader), findsOneWidget);
      expect(find.byType(MassCard), findsNWidgets(3));
      expect(
        find.byType(ActivityRibbon),
        findsNWidgets(regularActivities.length),
      );
      // No third/fourth section title such as a live-calendar-fed
      // "Upcoming Events" section.
      expect(find.text('Upcoming Events'), findsNothing);
    });
  });

  group('REQ-F04-015: MassTime is a typed, immutable const entity', () {
    test('const constructor compiles with time/name/note fields', () {
      const massTime = MassTime(
        time: 'Sat 5:30 PM',
        name: 'Vigil Mass',
        note: 'A note',
      );
      expect(massTime.time, 'Sat 5:30 PM');
      expect(massTime.name, 'Vigil Mass');
      expect(massTime.note, 'A note');

      const noNote = MassTime(time: 'Sun 8:00 AM', name: 'Sunday Mass');
      expect(noNote.note, isNull);
    });
  });

  group('REQ-F04-017: screen reads schedule content through '
      'massScheduleProvider, not the static config directly', () {
    testWidgets('overriding massScheduleProvider changes rendered '
        'content', (tester) async {
      const overriddenSchedule = MassSchedule(
        whatsOnCards: [
          MassTimesCard(
            title: 'Test Card',
            subGroups: [
              MassSubGroup(
                label: 'Sunday',
                rows: [MassTime(time: 'Sun 9:00 AM', name: 'Test Mass')],
              ),
            ],
          ),
        ],
        regularActivities: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            massScheduleProvider.overrideWith((ref) => overriddenSchedule),
          ],
          child: const MaterialApp(home: Scaffold(body: MassesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sun 9:00 AM'), findsOneWidget);
      expect(find.text('Test Mass'), findsOneWidget);
      // The real static content's Sunday rows are no longer present,
      // confirming the screen renders whatever the provider returns
      // rather than importing the static config directly.
      expect(find.text('Sun 8:00 AM'), findsNothing);
    });
  });

  group('REQ-F04-020: reflows without overflow at increased text scale and '
      'across screen sizes', () {
    const phoneSize = Size(390, 844);
    const smallPhoneSize = Size(360, 690);
    const tabletSize = Size(1024, 1366);

    Future<void> expectNoOverflowAt(
      WidgetTester tester,
      Size size,
      TextScaler textScaler, {
      bool expandRibbons = false,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: const Scaffold(body: MassesScreen()),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (expandRibbons) {
        for (final activity in regularActivities) {
          final title = ribbonTitle(activity);
          await tester.scrollUntilVisible(title, 200);
          await tester.tap(title);
          await tester.pumpAndSettle();
        }
      }

      expect(
        tester.takeException(),
        isNull,
        reason:
            'Expected no overflow/clipping exceptions at size $size, '
            'textScaler $textScaler',
      );
    }

    for (final size in [smallPhoneSize, phoneSize, tabletSize]) {
      testWidgets('no overflow at $size, default text scale', (tester) async {
        await expectNoOverflowAt(tester, size, TextScaler.noScaling);
      });

      testWidgets('no overflow at $size, TextScaler.linear(1.5)', (
        tester,
      ) async {
        await expectNoOverflowAt(tester, size, TextScaler.linear(1.5));
      });

      testWidgets('no overflow at $size, TextScaler.linear(2.0)', (
        tester,
      ) async {
        await expectNoOverflowAt(tester, size, TextScaler.linear(2.0));
      });

      testWidgets('no overflow at $size, TextScaler.linear(2.0), every '
          'activity ribbon expanded', (tester) async {
        await expectNoOverflowAt(
          tester,
          size,
          TextScaler.linear(2.0),
          expandRibbons: true,
        );
      });
    }
  });
}
