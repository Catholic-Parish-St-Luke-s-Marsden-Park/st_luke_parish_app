import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministry_detail_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_card.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_category_header.dart';

import '../../helpers/fake_ministries_repository.dart';

/// Covers the Ministries tab with data loaded: REQ-F03-001..004, now driven
/// by a fake repository serving the bundled fallback asset (REQ-F08-021).
/// Loading/error/empty/refresh states are in
/// `ministries_screen_states_test.dart`.
void main() {
  final fallback = loadFallbackMinistries();

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
      ProviderScope(
        retry: noAutomaticRetry,
        overrides: [
          ministriesRepositoryProvider.overrideWith(
            (ref) async => FakeMinistriesRepository(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: MinistriesScreen())),
      ),
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

  group('REQ-F03-002 / REQ-F08-004: categories and cards render in API '
      'order', () {
    testWidgets('a category header renders for each category, in order', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      final headers = tester
          .widgetList<MinistryCategoryHeader>(
            find.byType(MinistryCategoryHeader),
          )
          .map((header) => header.category)
          .toList();
      expect(headers, fallback.map((category) => category.name).toList());
      for (final category in fallback) {
        expect(find.text(category.name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('all 16 ministry cards are reachable, in order', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      final cardIds = tester
          .widgetList<MinistryCard>(find.byType(MinistryCard))
          .map((card) => card.ministry.id)
          .toList();
      expect(cardIds, hasLength(16));
      expect(
        cardIds,
        fallback
            .expand((category) => category.ministries)
            .map((ministry) => ministry.id)
            .toList(),
      );
    });
  });

  group('REQ-F03-003: ministry card renders name/membersLine/dayLine', () {
    testWidgets('a card shows its ministry name, membersLine, and dayLine', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      // Scoped to the Music Ministry card specifically: several ministries
      // share the same dayLine text (e.g. "Weekend Masses"), so asserting
      // findsOneWidget on the raw text alone would be ambiguous.
      final music = fallbackMinistry('music');
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
