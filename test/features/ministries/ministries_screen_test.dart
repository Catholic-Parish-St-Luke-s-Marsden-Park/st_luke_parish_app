import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministry_detail_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_row.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_category_header.dart';

import '../../helpers/fake_ministries_repository.dart';

/// Covers the Ministries tab with data loaded: REQ-F03-001..004, now driven
/// by a fake repository serving the bundled fallback asset (REQ-F08-021).
/// Loading/error/empty/refresh states are in
/// `ministries_screen_states_test.dart`.
void main() {
  final fallback = loadFallbackMinistries();

  Future<void> pumpMinistriesScreen(WidgetTester tester) async {
    // MinistriesScreen renders 16 rows across 4 category sections, well
    // taller than the default 800x600 test surface — use a tall surface so
    // every row/category header is built and findable without needing to
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

  group('REQ-F03-002 / REQ-F08-004: categories and rows render in API '
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

    testWidgets('all 16 ministry rows are reachable, in order', (tester) async {
      await pumpMinistriesScreen(tester);

      final rowIds = tester
          .widgetList<MinistryRow>(find.byType(MinistryRow))
          .map((row) => row.ministry.id)
          .toList();
      expect(rowIds, hasLength(16));
      expect(
        rowIds,
        fallback
            .expand((category) => category.ministries)
            .map((ministry) => ministry.id)
            .toList(),
      );
    });
  });

  group('REQ-F03-003: ministry row renders name and "members · day"', () {
    testWidgets('a row shows its ministry name and members · day line', (
      tester,
    ) async {
      await pumpMinistriesScreen(tester);

      final music = fallbackMinistry('music');
      final rowFinder = find.ancestor(
        of: find.text(music.name),
        matching: find.byType(MinistryRow),
      );
      expect(rowFinder, findsOneWidget);
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.text('${music.membersLine} · ${music.dayLine}'),
        ),
        findsOneWidget,
      );
    });
  });

  group('REQ-F03-004: tapping a ministry row navigates to its detail '
      'screen', () {
    testWidgets('tapping the Music Ministry row opens its detail screen', (
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
