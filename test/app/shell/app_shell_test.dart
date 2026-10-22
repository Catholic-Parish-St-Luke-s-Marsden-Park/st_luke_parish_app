import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/shared/widgets/parish_name_lockup.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/about_st_lukes_section.dart';
import 'package:st_luke_parish_app/app/shell/app_shell.dart';
import 'package:st_luke_parish_app/app/shell/bottom_nav.dart';
import 'package:st_luke_parish_app/app/shell/nav_index_provider.dart';
import 'package:st_luke_parish_app/app/shell/widgets/pulsing_nav_icon.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';
import 'package:st_luke_parish_app/core/theme/app_theme.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/masses_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/news/presentation/screens/news_screen.dart';
import 'package:st_luke_parish_app/features/parish/domain/entities/parish_notice.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';
import 'package:st_luke_parish_app/features/parish/presentation/providers/parish_notice_provider.dart';
import 'package:st_luke_parish_app/features/parish/presentation/screens/parish_screen.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/broadcasting_megaphone.dart';
import 'package:st_luke_parish_app/features/resources/domain/failures/reflections_failure.dart';
import 'package:st_luke_parish_app/features/resources/presentation/providers/reflections_provider.dart';

/// Covers REQ-F01-002 (bottom nav: 6 destinations, correct labels/icons,
/// IndexedStack tab-state preservation), REQ-F01-003 (side drawer: exactly
/// 2 entries), and REQ-F01-005 (generated Riverpod provider drives the
/// selected tab).
final _notice = ParishNotice(
  imageUrl: 'https://stlukesmarsdenpark.org.au/notice.jpg',
  imageBytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  ),
);

class _FakeUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

Future<_FakeUrlLauncher> _pumpShell(
  WidgetTester tester, {
  bool withNotice = true,
}) async {
  final notice = withNotice ? _notice : null;
  final launcher = _FakeUrlLauncher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        urlLauncherServiceProvider.overrideWithValue(launcher),
        // Never read the real reflections page from a widget test.
        latestReflectionProvider.overrideWith(
          (ref) => Future.error(const ReflectionsNetworkFailure('offline')),
        ),
        // Nor the parish home page's pop-up.
        currentParishNoticeProvider.overrideWith((ref) async => notice),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const AppShell()),
    ),
  );
  await tester.pumpAndSettle();
  return launcher;
}

/// How much the menu header is shrunk to fit (1 when it is not).
double _drawerScale(WidgetTester tester, Finder name) =>
    (tester.getTopRight(name).dx - tester.getTopLeft(name).dx) /
    tester.renderObject<RenderBox>(name).size.width;

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
              "${destination.label == 'Donate'}",
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

    testWidgets(
      "Donate's icon is always AppColors.gold, matching the parish PWA, "
      'regardless of which tab is selected (every other destination '
      "follows the nav bar's normal selected/unselected theming instead)",
      (tester) async {
        await _pumpShell(tester);

        PulsingNavIcon donateIcon() =>
            tester.widget<PulsingNavIcon>(find.byType(PulsingNavIcon));

        // Not selected (Parish, index 0, is the initial tab).
        expect(donateIcon().color, AppColors.gold);

        // Still gold once Donate itself is selected. Donate's WebView
        // loading state uses an indefinitely-animating
        // CircularProgressIndicator, which would make pumpAndSettle hang
        // forever -- a bounded pump is sufficient here, same pattern as
        // app_bar_chrome_test.dart's REQ-F02-019 test.
        await tester.tap(find.text('Donate'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(donateIcon().color, AppColors.gold);

        // Every other destination has no fixed color override -- they
        // follow the shared nav bar theme instead.
        for (final destination in bottomNavDestinations) {
          if (destination.label == 'Donate') continue;
          expect(
            destination.color,
            isNull,
            reason: '${destination.label} should not override its color',
          );
        }
      },
    );

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
    testWidgets('opens and shows exactly 4 entries: Resources, Faith '
        'Formation, The Rosary and Divine Mercy Chaplet (no Prayer Request)', (
      tester,
    ) async {
      await _pumpShell(tester);

      final scaffoldState = tester.state<ScaffoldState>(
        find.byType(Scaffold).first,
      );
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);

      // Scoped to the drawer: the Parish tab's About St Luke's card is also
      // a ListTile (inside its ExpansionTile).
      final listTiles = tester.widgetList<ListTile>(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(ListTile),
        ),
      );
      expect(listTiles.length, 4);
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Divine Mercy Chaplet'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('The Rosary'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Faith Formation'),
        ),
        findsOneWidget,
      );

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
        findsNothing,
      );
    });

    testWidgets("the header shows the St Luke's emblem beside the name", (
      tester,
    ) async {
      await _pumpShell(tester);
      tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      await tester.pumpAndSettle();

      final emblem = find.descendant(
        of: find.byType(Drawer),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  AboutStLukesSection.emblemAsset,
        ),
      );
      expect(emblem, findsOneWidget);
      final name = find.descendant(
        of: find.byType(Drawer),
        matching: find.text("St Luke's Catholic Parish"),
      );
      expect(name, findsOneWidget);
      expect(tester.getCenter(emblem).dx, lessThan(tester.getTopLeft(name).dx));
      // MARSDEN PARK beneath, as on the parish logo; two lines in all.
      final place = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('MARSDEN PARK'),
      );
      expect(place, findsOneWidget);
      expect(
        tester.getTopLeft(place).dy,
        greaterThan(tester.getBottomLeft(name).dy),
      );
      expect(
        find.bySemanticsLabel("St Luke's Catholic Parish, Marsden Park"),
        findsOneWidget,
      );
    });

    for (final scale in const [1.0, 2.0]) {
      testWidgets('MARSDEN PARK is spaced to end with the name at text '
          'x$scale', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _pumpShell(tester);
        tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
        await tester.pumpAndSettle();

        Finder inMenu(Finder f) =>
            find.descendant(of: find.byType(Drawer), matching: f);
        final name = inMenu(find.text(ParishNameLockup.name));
        final place = inMenu(find.text(ParishNameLockup.place));
        final spacing = tester.widget<Text>(place).style!.letterSpacing!;
        expect(spacing, greaterThan(0));
        // Letter spacing sits half before and half after each letter, and
        // the test font's letters fill their boxes, so the M's ink starts
        // half a gap in from the line's box and the K's ends half a gap
        // before it. Both should meet the name's edges.
        final half = spacing / 2 * _drawerScale(tester, name);
        expect(
          tester.getTopLeft(place).dx + half,
          moreOrLessEquals(tester.getTopLeft(name).dx, epsilon: 0.5),
        );
        expect(
          tester.getTopRight(place).dx - half,
          moreOrLessEquals(tester.getTopRight(name).dx, epsilon: 0.5),
        );
        expect(tester.takeException(), isNull);
      });
    }

    for (final scale in const [1.0, 2.0]) {
      testWidgets('the header fits on a small phone at text x$scale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 690);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _pumpShell(tester);
        tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('MARSDEN PARK'),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

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

    testWidgets('tapping The Rosary opens The Rosary page', (tester) async {
      await _pumpShell(tester);

      tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('The Rosary'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'The Rosary'), findsOneWidget);
      expect(find.text('Pray the Rosary'), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('tapping Faith Formation opens its own page of links', (
      tester,
    ) async {
      await _pumpShell(tester);

      tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Faith Formation'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Faith Formation'), findsOneWidget);
      expect(find.text('FORMED'), findsOneWidget);
      expect(find.text('On Our Knees'), findsOneWidget);
      expect(find.text('Vatican News'), findsNothing);
    });
  });

  group('Floating announcement button', () {
    testWidgets('shows a megaphone button while the website has a pop-up; '
        'tapping it opens the announcement', (tester) async {
      await _pumpShell(tester);

      final button = find.byType(FloatingActionButton);
      expect(button, findsOneWidget);
      expect(
        find.descendant(
          of: button,
          matching: find.byType(BroadcastingMegaphone),
        ),
        findsOneWidget,
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));

      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Special Announcement'), findsOneWidget);
      final image = tester.widget<Image>(
        find.descendant(of: find.byType(Dialog), matching: find.byType(Image)),
      );
      expect((image.image as MemoryImage).bytes, _notice.imageBytes);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('the button is only on the Parish tab', (tester) async {
      await _pumpShell(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Frame-by-frame pumps: some tabs show endless loading spinners, and
      // the button animates out.
      Future<void> settle() async {
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      for (final label in ['Masses', 'News', 'Ministries', 'Contact']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await settle();
        expect(find.byType(FloatingActionButton), findsNothing, reason: label);
      }

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Parish'),
        ),
      );
      await settle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('no button at all when the website has no pop-up', (
      tester,
    ) async {
      await _pumpShell(tester, withNotice: false);

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('no button when the website cannot be reached', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestReflectionProvider.overrideWith(
              (ref) => Future.error(const ReflectionsNetworkFailure('offline')),
            ),
            currentParishNoticeProvider.overrideWith(
              (ref) => Future.error(const ParishDocumentsNetworkFailure('x')),
            ),
          ],
          child: MaterialApp(theme: AppTheme.light(), home: const AppShell()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
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
