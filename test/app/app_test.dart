import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/app.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';
import 'package:st_luke_parish_app/core/theme/app_shapes.dart';

/// Covers REQ-F01-001 (themed shell: palette/fonts/radii, app builds and
/// renders without errors) and REQ-F01-006 (no overflow/clipping across
/// representative phone and tablet screen sizes), exercised through the
/// full `StLukeApp` root widget (go_router + ProviderScope + AppShell).
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StLukeApp()));
    await tester.pumpAndSettle();
  }

  group('REQ-F01-001: themed shell', () {
    testWidgets('renders StLukeApp with the navy/gold/cream theme applied '
        'and no build errors', (tester) async {
      await pumpApp(tester);

      expect(tester.takeException(), isNull);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme!;

      expect(theme.scaffoldBackgroundColor, AppColors.cream);
      expect(theme.appBarTheme.backgroundColor, AppColors.primaryNavy);
      expect(theme.colorScheme.primary, AppColors.primaryNavy);
      expect(theme.colorScheme.secondary, AppColors.gold);
      expect(theme.navigationBarTheme.backgroundColor, AppColors.primaryNavy);
    });

    test('corner radii tokens match acceptance criteria', () {
      expect(AppShapes.cardRadius, 12.0);
      expect(AppShapes.pillRadius, 20.0);
    });

    testWidgets('app shell (Scaffold, AppBar, NavigationBar) renders under '
        'the app root', (tester) async {
      await pumpApp(tester);

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Parish'), findsWidgets);
    });
  });

  group('REQ-F01-006: responsive layout, no overflow/clipping', () {
    const phoneSize = Size(390, 844); // iPhone 12-class phone
    const smallPhoneSize = Size(360, 690); // small/older Android phone
    const tabletSize = Size(1024, 1366); // iPad-class tablet, portrait

    Future<void> expectNoOverflowAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no overflow/clipping exceptions at size $size',
      );
    }

    testWidgets('renders without overflow at a small phone size', (
      tester,
    ) async {
      await expectNoOverflowAt(tester, smallPhoneSize);
    });

    testWidgets('renders without overflow at a representative phone size', (
      tester,
    ) async {
      await expectNoOverflowAt(tester, phoneSize);
    });

    testWidgets('renders without overflow at a representative tablet size', (
      tester,
    ) async {
      await expectNoOverflowAt(tester, tabletSize);
    });

    testWidgets('drawer renders without overflow at phone and tablet sizes', (
      tester,
    ) async {
      for (final size in [phoneSize, tabletSize]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pumpApp(tester);

        final scaffoldState = tester.state<ScaffoldState>(
          find.byType(Scaffold).first,
        );
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Expected no overflow exceptions opening drawer at $size',
        );
      }
    });
  });
}
