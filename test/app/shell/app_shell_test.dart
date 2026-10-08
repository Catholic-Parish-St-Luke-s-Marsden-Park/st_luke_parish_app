import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/shell/app_shell.dart';
import 'package:st_luke_parish_app/app/shell/bottom_nav.dart';
import 'package:st_luke_parish_app/app/shell/nav_index_provider.dart';
import 'package:st_luke_parish_app/app/shell/widgets/pulsing_nav_icon.dart';
import 'package:st_luke_parish_app/core/theme/app_theme.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/masses_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/news/presentation/screens/news_screen.dart';
import 'package:st_luke_parish_app/features/parish/presentation/screens/parish_screen.dart';

/// Covers REQ-F01-002 (bottom nav: 6 destinations, correct labels/icons,
/// IndexedStack tab-state preservation), REQ-F01-003 (side drawer: exactly
/// 2 entries), and REQ-F01-005 (generated Riverpod provider drives the
/// selected tab).
Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: AppTheme.light(), home: const AppShell()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('REQ-F01-002: bottom navigation', () {
    testWidgets('shows exactly 6 destinations with correct labels', (
      tester,
    ) async {
      await _pumpShell(tester);

      expect(bottomNavDestinations.length, 6);

      final navigationBarFinder = find.byType(NavigationBar);
      expect(navigationBarFinder, findsOneWidget);

      final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);
      expect(navigationBar.destinations.length, 6);

      const expectedLabels = [
        'Parish',
        'Masses',
        'News',
        'Ministries',
        'Contact',
        'Donate',
      ];
      for (final label in expectedLabels) {
        expect(
          find.descendant(of: navigationBarFinder, matching: find.text(label)),
          findsOneWidget,
          reason: 'Expected bottom nav destination "$label"',
        );
      }

      const expectedIcons = [
        Icons.church_rounded,
        Icons.calendar_month_rounded,
        Icons.article_rounded,
        Icons.groups_rounded,
        Icons.location_on_rounded,
        Icons.favorite_rounded,
      ];
      for (var i = 0; i < expectedIcons.length; i++) {
        expect(bottomNavDestinations[i].icon, expectedIcons[i]);
      }
    });

    testWidgets('only the Donate destination pulses; every other icon is '
        'static', (tester) async {
      await _pumpShell(tester);

      // Data-level: exactly one destination (Donate, the last of the 6)
      // opts into the pulse, matching the parish PWA's own Donate-only
      // heartbeat animation.
      for (final destination in bottomNavDestinations) {
        expect(
          destination.pulse,
          destination.label == 'Donate',
          reason:
              '${destination.label} pulse flag should be '
              '${destination.label == 'Donate'}',
        );
      }

      // Rendered: the Donate destination's icon is a PulsingNavIcon, and
      // no other destination renders one.
      final navigationBarFinder = find.byType(NavigationBar);
      expect(
        find.descendant(
          of: navigationBarFinder,
          matching: find.byType(PulsingNavIcon),
        ),
        findsOneWidget,
      );

      final pulsingIcon = tester.widget<PulsingNavIcon>(
        find.byType(PulsingNavIcon),
      );
      expect(pulsingIcon.icon, Icons.favorite_rounded);
    });

    testWidgets('tapping a destination updates the selected nav index '
        'provider and switches the visible tab', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light(), home: const AppShell()),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(selectedNavIndexProvider), 0);
      expect(find.text('Parish'), findsWidgets);

      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();

      expect(container.read(selectedNavIndexProvider), 2);
      expect(find.text('News & Bulletins'), findsWidgets);
    });

    testWidgets('switching tabs preserves each visited tab in the IndexedStack '
        'instead of disposing it', (tester) async {
      await _pumpShell(tester);

      // Tab 0 (Parish) is built by default.
      expect(
        find.byType(ParishScreen, skipOffstage: false),
        findsOneWidget,
        reason: 'Parish tab should be built on initial load',
      );
      // Other tabs are not yet built (lazy tab build).
      expect(find.byType(MassesScreen, skipOffstage: false), findsNothing);

      // Visit tab 1 (Masses).
      await tester.tap(find.text('Masses'));
      await tester.pumpAndSettle();
      expect(find.byType(MassesScreen), findsOneWidget);

      // Visit tab 2 (News).
      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();
      expect(find.byType(NewsScreen), findsOneWidget);

      // Previously visited tabs (Parish, Masses) remain in the widget
      // tree (offstage, inside IndexedStack) rather than being disposed,
      // proving IndexedStack-based state preservation.
      expect(
        find.byType(ParishScreen, skipOffstage: false),
        findsOneWidget,
        reason: 'Parish tab widget should still be in the tree, offstage',
      );
      expect(
        find.byType(MassesScreen, skipOffstage: false),
        findsOneWidget,
        reason: 'Masses tab widget should still be in the tree, offstage',
      );

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, 2);

      // A never-visited tab (Ministries, index 3) is not built yet — its
      // slot is a lazy placeholder.
      expect(find.byType(MinistriesScreen, skipOffstage: false), findsNothing);
    });
  });

  group('REQ-F01-003: side drawer', () {
    testWidgets('opens and shows exactly 2 entries: Resources and '
        'Prayer Request', (tester) async {
      await _pumpShell(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.length, 2);

      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Resources'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Prayer Request'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping Resources navigates to the Resources screen', (
      tester,
    ) async {
      await _pumpShell(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resources'));
      await tester.pumpAndSettle();

      // AppBar title 'Resources' should now be showing on the pushed
      // ResourcesScreen (distinct from the drawer entry we just tapped).
      expect(find.widgetWithText(AppBar, 'Resources'), findsOneWidget);
    });
  });

  group('REQ-F01-005: Riverpod-driven shell state', () {
    test('selectedNavIndexProvider starts at 0 and updates via select()', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedNavIndexProvider), 0);

      container.read(selectedNavIndexProvider.notifier).select(4);

      expect(container.read(selectedNavIndexProvider), 4);
    });
  });
}
