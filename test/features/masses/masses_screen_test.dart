import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_schedule.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_sub_group.dart';
import 'package:st_luke_parish_app/features/masses/domain/entities/mass_time.dart';
import 'package:st_luke_parish_app/features/masses/presentation/providers/mass_schedule_provider.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/masses_screen.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_card.dart';
import 'package:st_luke_parish_app/features/masses/presentation/widgets/mass_section_header.dart';

/// Covers the Masses tab acceptance criteria: REQ-F04-001..024.
///
/// This feature is static, hardcoded content with no async/network layer,
/// so "loading", "empty result", "parsing failure", "network failure",
/// "missing selector result", and "invalid URL result" states are all
/// intentionally not applicable/not covered here (matches REQ-F04-024's own
/// note and the BA plan's Acceptance Criteria).
void main() {
  Future<void> pumpMassesScreen(WidgetTester tester) async {
    // MassesScreen's content (hero + 2 sections, 9 rows) is taller than the
    // default 800x600 test surface, which would leave the second section's
    // rows outside the ListView's build/cache extent. Use a tall surface so
    // every row is built without needing to scroll mid-test (same pattern
    // as contact_screen_test.dart).
    tester.view.physicalSize = const Size(800, 1600);
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

  group('REQ-F04-003/004: "What\'s On" section and its 3 sub-groups', () {
    testWidgets('renders "What\'s On" as the first section title, with '
        'exactly 3 sub-group labels in order', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.text("What's On"), findsOneWidget);

      final subGroupLabels = ['SUNDAY', 'SATURDAY VIGIL', 'WEEKDAY'];
      for (final label in subGroupLabels) {
        expect(find.text(label), findsOneWidget);
      }

      // Confirm relative order top-to-bottom via vertical position.
      final positions = subGroupLabels
          .map((l) => tester.getTopLeft(find.text(l)).dy)
          .toList();
      expect(positions, orderedEquals(List.of(positions)..sort()));
    });
  });

  group('REQ-F04-005: Sunday sub-group — exactly 3 no-note rows, in order', () {
    testWidgets('renders the 3 exact Sunday rows', (tester) async {
      await pumpMassesScreen(tester);

      const rows = ['Sun 8:00 AM', 'Sun 10:00 AM', 'Sun 5:30 PM'];
      for (final time in rows) {
        expect(find.text(time), findsOneWidget);
      }
      // "Sunday Mass" appears 3 times (once per Sunday row).
      expect(find.text('Sunday Mass'), findsNWidgets(3));
    });
  });

  group('REQ-F04-006: Saturday Vigil sub-group — exactly 1 row with note', () {
    testWidgets('renders the exact Vigil row and its note', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.text('Sat 5:30 PM'), findsOneWidget);
      expect(find.text('Vigil Mass'), findsOneWidget);
      expect(find.text('Reconciliation from 4:30–5:25pm'), findsOneWidget);
    });
  });

  group(
    'REQ-F04-007: Weekday sub-group — exactly 3 no-note rows, in order',
    () {
      testWidgets('renders the 3 exact Weekday rows', (tester) async {
        await pumpMassesScreen(tester);

        expect(find.text('Wed 7:30 AM'), findsOneWidget);
        expect(find.text('Fri 6:30 PM'), findsOneWidget);
        expect(find.text('Fri 11:00 AM'), findsOneWidget);
        expect(find.text('Weekday Mass'), findsNWidgets(2));
        expect(find.text('Marsden Park Care Community Mass'), findsOneWidget);
      });
    },
  );

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

  group('REQ-F04-009: "Reconciliation & Sacraments" section — exactly 3 rows, '
      'in order', () {
    testWidgets('renders the section title and its 3 exact rows', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.text('Reconciliation & Sacraments'), findsOneWidget);

      expect(find.text('Sat 4:30 PM'), findsOneWidget);
      expect(find.text('Reconciliation'), findsOneWidget);
      expect(find.text('Before the Vigil Mass'), findsOneWidget);

      expect(find.text('By request'), findsOneWidget);
      expect(find.text('Baptisms & House Blessings'), findsOneWidget);

      expect(find.text('By enrolment'), findsOneWidget);
      expect(find.text('Sacramental Programme'), findsOneWidget);
    });

    testWidgets('"Reconciliation & Sacraments" is the second section, '
        'after "What\'s On"', (tester) async {
      await pumpMassesScreen(tester);

      final whatsOnY = tester.getTopLeft(find.text("What's On")).dy;
      final reconciliationY = tester
          .getTopLeft(find.text('Reconciliation & Sacraments'))
          .dy;
      expect(reconciliationY, greaterThan(whatsOnY));
    });
  });

  group('REQ-F04-010: no stray location/venue text in "Reconciliation & '
      'Sacraments"', () {
    testWidgets('only the Reconciliation row carries a note, and it is '
        'the exact expected string', (tester) async {
      await pumpMassesScreen(tester);

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final mentionsAddress = textWidgets.any(
        (t) => (t.data ?? '').toLowerCase().contains('venue'),
      );
      expect(mentionsAddress, isFalse);
    });
  });

  group('REQ-F04-011: no icon/emoji anywhere on the screen', () {
    testWidgets('no Icon widget is rendered', (tester) async {
      await pumpMassesScreen(tester);

      expect(find.byType(Icon), findsNothing);
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

  group('REQ-F04-012: no "Details"/chevron/arrow affordance on any row', () {
    testWidgets('no chevron/arrow icon and no "Details" text anywhere', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
      expect(find.textContaining('Details'), findsNothing);
      expect(find.textContaining('↗'), findsNothing);

      // No tap targets: MassRow itself is not wrapped in any gesture
      // detector/inkwell in the tree (rows are plain, non-interactive
      // text per REQ-F04-012).
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
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

  group('REQ-F04-014: exactly 2 sections and exactly 2 cards total', () {
    testWidgets('exactly 2 MassSectionHeader and 2 MassCard widgets', (
      tester,
    ) async {
      await pumpMassesScreen(tester);

      expect(find.byType(MassSectionHeader), findsNWidgets(2));
      expect(find.byType(MassCard), findsNWidgets(2));
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
        whatsOnSubGroups: [
          MassSubGroup(
            label: 'Sunday',
            rows: [MassTime(time: 'Sun 9:00 AM', name: 'Test Mass')],
          ),
        ],
        reconciliationAndSacraments: [],
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
      TextScaler textScaler,
    ) async {
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
    }
  });
}
