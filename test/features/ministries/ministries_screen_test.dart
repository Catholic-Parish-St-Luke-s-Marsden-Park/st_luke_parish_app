import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ministries/data/config/static_ministries_config.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministry_detail_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_card.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_category_header.dart';

/// Covers the Ministries tab acceptance criteria: REQ-F03-001..010.
void main() {
  Future<void> pumpMinistriesScreen(WidgetTester tester) async {
    // MinistriesScreen renders 16 cards across 4 category sections, well
    // taller than the default 800x600 test surface — use a tall surface so
    // every card/category header is built and findable without needing to
    // scroll mid-test.
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MinistriesScreen())),
    );
    await tester.pumpAndSettle();
  }

  group('REQ-F03-001: MinistriesScreen renders real content, not a '
      'placeholder', () {
    testWidgets('does not render the generic PlaceholderScreen icon', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.groups_rounded), findsNothing);
      expect(find.text('Ministries & Groups'), findsOneWidget);
    });
  });

  group('REQ-F03-002: static config has exactly 16 ministries under exactly '
      '4 categories', () {
    test('exactly 16 ministries', () {
      expect(staticMinistries.length, 16);
    });

    test('exactly 4 categories, in order', () {
      expect(ministryCategories, [
        'Liturgy & Worship',
        'Children & Youth',
        'Community & Outreach',
        'Operations & Governance',
      ]);
    });

    test('every ministry belongs to one of the 4 categories', () {
      for (final ministry in staticMinistries) {
        expect(ministryCategories, contains(ministry.category));
      }
    });

    test('exact id/name pairs grouped under the exact expected category', () {
      const expected = {
        'Liturgy & Worship': {
          'music': 'Music Ministry',
          'liturgical': 'Liturgical Ministry',
          'altar': 'Ministers of the Altar',
          'emohc': 'Extraordinary Ministers of Holy Communion',
        },
        'Children & Youth': {
          'youth': 'Luke-18',
          'childrens': "Children's Liturgy",
          'sacramental': 'Sacramental Process',
          'sre': 'SRE Ministry',
        },
        'Community & Outreach': {
          'welcome': 'Welcome Ministry',
          'hospitality': 'Hospitality Team',
          'fundraising': 'Fundraising Team',
          'scripture': 'Walking with Christ',
        },
        'Operations & Governance': {
          'finance': 'Finance Committee',
          'ict': 'ICT Committee',
          'logistics': 'Logistics Team',
          'maintenance': 'Maintenance Ministry',
        },
      };

      for (final category in expected.keys) {
        final actualPairs = {
          for (final m in staticMinistries.where((m) => m.category == category))
            m.id: m.name,
        };
        expect(actualPairs, expected[category]);
      }

      // No unexpected ministries beyond the 16 enumerated above.
      expect(
        staticMinistries.map((m) => m.id).toSet(),
        expected.values.expand((m) => m.keys).toSet(),
      );
    });

    testWidgets('a category header renders for each of the 4 categories', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      expect(find.byType(MinistryCategoryHeader), findsNWidgets(4));
      for (final category in ministryCategories) {
        expect(find.text(category.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('all 16 ministry cards are reachable in the grid', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      expect(find.byType(MinistryCard), findsNWidgets(16));
    });
  });

  group('REQ-F03-003: ministry card renders name/membersLine/dayLine, never '
      'the emoji', () {
    testWidgets('a card shows its ministry name, membersLine, and dayLine', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      // Scoped to the Music Ministry card specifically: several ministries
      // share the same dayLine text (e.g. "Weekend Masses"), so asserting
      // findsOneWidget on the raw text alone would be ambiguous.
      final music = staticMinistries.firstWhere((m) => m.id == 'music');
      final cardFinder = find.ancestor(
        of: find.text(music.name),
        matching: find.byType(MinistryCard),
      );
      expect(cardFinder, findsOneWidget);
      expect(
        find.descendant(of: cardFinder, matching: find.text(music.membersLine)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: cardFinder, matching: find.text(music.dayLine)),
        findsOneWidget,
      );
    });

    testWidgets('no Text widget anywhere on the Ministries grid renders any '
        "ministry's emoji value", (tester) async {
      await pumpMinistriesScreen(tester);

      final renderedTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toSet();

      for (final ministry in staticMinistries) {
        expect(
          renderedTexts,
          isNot(contains(ministry.emoji)),
          reason:
              '${ministry.id} emoji "${ministry.emoji}" must not be '
              'rendered by any Text widget on the Ministries grid',
        );
        for (final text in renderedTexts) {
          expect(
            text.contains(ministry.emoji),
            isFalse,
            reason:
                '${ministry.id} emoji "${ministry.emoji}" must not '
                'appear as a substring of any rendered Text',
          );
        }
      }
    });
  });

  group('REQ-F03-004: tapping a ministry card navigates to its detail '
      'screen', () {
    testWidgets('tapping the Music Ministry card opens its detail screen', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      await tester.tap(find.text('Music Ministry'));
      await tester.pumpAndSettle();

      expect(find.byType(MinistryDetailScreen), findsOneWidget);
      // The detail screen's hero shows the ministry's name.
      expect(find.text('Music Ministry'), findsOneWidget);
    });
  });
}
