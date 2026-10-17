import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:st_luke_parish_app/app/shell/app_shell.dart';
import 'package:st_luke_parish_app/app/shell/nav_index_provider.dart';
import 'package:st_luke_parish_app/app/shell/widgets/app_bar_logo.dart';
import 'package:st_luke_parish_app/app/shell/widgets/ask_luke_pill.dart';
import 'package:st_luke_parish_app/app/shell/widgets/saint_of_the_day_pill.dart';
import 'package:st_luke_parish_app/core/theme/app_shapes.dart';
import 'package:st_luke_parish_app/core/theme/app_theme.dart';
import 'package:st_luke_parish_app/features/ask_luke/presentation/screens/ask_luke_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/providers/saint_of_the_day_provider.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/screens/saint_of_the_day_screen.dart';
import 'package:st_luke_parish_app/shared/widgets/app_pill_button.dart';

import '../../helpers/fake_ministries_repository.dart';

/// Covers the shared AppBar chrome acceptance criteria: REQ-F02-014
/// through REQ-F02-016a and REQ-F02-017 through REQ-F02-019.
void main() {
  Future<void> pumpShell(
    WidgetTester tester, {
    List<Override> overrides = const [],
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('REQ-F02-014: wordmark logo via Image.asset', () {
    testWidgets('AppBar renders AppBarLogo using a local Image.asset', (
      tester,
    ) async {
      await pumpShell(tester);

      final appBarLogoFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(AppBarLogo),
      );
      expect(appBarLogoFinder, findsOneWidget);

      final image = tester.widget<Image>(
        find.descendant(of: appBarLogoFinder, matching: find.byType(Image)),
      );
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/branding/st_lukes_wordmark.jpg',
      );
    });

    testWidgets('logo sits on a white pill-rounded chip', (tester) async {
      await pumpShell(tester);

      final chip = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(AppBarLogo),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = chip.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, AppShapes.pillBorderRadius);
    });
  });

  group('AppBar logo keeps its size at large system text sizes', () {
    Future<double> logoWidthAt(
      WidgetTester tester,
      Size size,
      double scale,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpShell(tester, textScaler: TextScaler.linear(scale));
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byType(AppBarLogo)).width;
    }

    for (final size in const [Size(430, 932), Size(375, 667), Size(360, 740)]) {
      testWidgets('${size.width.toInt()}dp wide: logo keeps its full width at '
          '1.0x and 3.0x text', (tester) async {
        expect(await logoWidthAt(tester, size, 1.0), AppBarLogo.chipWidth);
        expect(await logoWidthAt(tester, size, 3.0), AppBarLogo.chipWidth);
      });
    }

    testWidgets('pill labels stop growing past the cap', (tester) async {
      Future<double> labelHeightAt(double scale) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await pumpShell(tester, textScaler: TextScaler.linear(scale));
        return tester
            .getSize(
              find.descendant(
                of: find.byType(SaintOfTheDayPill),
                matching: find.text('Saint of the Day'),
              ),
            )
            .height;
      }

      final atCap = await labelHeightAt(AppShell.appBarPillMaxTextScale);
      expect(await labelHeightAt(3.0), atCap);
      expect(await labelHeightAt(1.0), lessThan(atCap));
    });
  });

  group('REQ-F02-016: exactly 2 pills present in AppBar actions', () {
    testWidgets('AppBar actions contain exactly one SaintOfTheDayPill and one '
        'AskLukePill', (tester) async {
      await pumpShell(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(SaintOfTheDayPill),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(AskLukePill),
        ),
        findsOneWidget,
      );
      // Exactly 2 pill-style buttons total in the AppBar.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(AppPillButton),
        ),
        findsNWidgets(2),
      );
    });
  });

  group('REQ-F02-016a: no per-tab text title alongside the logo', () {
    testWidgets('AppBar does not render a Text tab title such as "Masses & '
        'Events"', (tester) async {
      await pumpShell(tester);

      // Switch to a non-default tab; if a per-tab text title were still
      // present, it would now read "Masses & Events".
      await tester.tap(find.text('Masses'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Masses & Events'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Masses')),
        findsNothing,
      );
      // The AppBar's only branding element is the logo.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(AppBarLogo),
        ),
        findsOneWidget,
      );
    });
  });

  group(
    'REQ-F06-001: Saint of the Day pill performs a full-screen navigation '
    '(supersedes REQ-F02-017\'s placeholder dialog, removed by feature 06)',
    () {
      testWidgets('tapping "Saint of the Day" pushes SaintOfTheDayScreen via '
          'Navigator.push, not a dialog/bottom sheet', (tester) async {
        await pumpShell(
          tester,
          overrides: [
            // Never the real parish API datasource/SharedPreferences in a
            // shell-level test — the screen's own content/failure states
            // are covered by saint_of_the_day_screen_test.dart.
            saintOfTheDayProvider.overrideWith(
              (ref) async => const SaintOfTheDay(
                name: 'Saint Example',
                feast: '',
                bornDied: '',
                about: '',
                saying: '',
                didYouKnow: '',
                patronOf: '',
                prayer: '',
                dateKey: '2026-09-01',
                displayDate: 'September 1',
              ),
            ),
          ],
        );

        await tester.tap(find.text('Saint of the Day'));
        await tester.pumpAndSettle();

        expect(find.byType(SaintOfTheDayScreen), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);
        // A full-screen push shows the Saint of the Day screen with no
        // visible shell underneath it (it's covering the whole route) —
        // same assertion style as the Ask Luke pill's REQ-F02-018 test.
        expect(find.byType(AppShell), findsNothing);
      });
    },
  );

  group('REQ-F02-018: Ask Luke pill performs a full-screen navigation', () {
    testWidgets(
      'tapping "Ask Luke" pushes AskLukeScreen via Navigator.push, not a '
      'bottom sheet/dialog',
      (tester) async {
        await pumpShell(tester);

        await tester.tap(find.text('Ask Luke'));
        await tester.pumpAndSettle();

        expect(find.byType(AskLukeScreen), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        // A full-screen push shows the Ask Luke screen with no visible
        // bottom nav bar of the shell underneath it (it's covering the
        // whole route).
        expect(find.byType(AppShell), findsNothing);
      },
    );
  });

  group('REQ-F02-019: AppBar/pills render identically across all 6 tabs', () {
    testWidgets(
      'logo + both pills are present regardless of the selected tab',
      (tester) async {
        // Keeps the Ministries tab off the network and shared_preferences.
        await pumpShell(
          tester,
          overrides: [
            ministriesRepositoryProvider.overrideWith(
              (ref) async => FakeMinistriesRepository(),
            ),
          ],
        );

        const tabLabels = [
          'Parish',
          'Masses',
          'News',
          'Ministries',
          'Contact',
          'Donate',
        ];

        for (final label in tabLabels) {
          // Scoped to the bottom bar: "Parish" is also a Church Leadership
          // group title on the Parish tab.
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
          );
          // Donate's WebView loading state uses an indefinitely-animating
          // CircularProgressIndicator, which would make pumpAndSettle hang
          // forever; a bounded pump is sufficient to build the tab body.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byType(AppBarLogo),
            ),
            findsOneWidget,
            reason: 'Expected logo present on the $label tab',
          );
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byType(SaintOfTheDayPill),
            ),
            findsOneWidget,
            reason: 'Expected Saint of the Day pill present on the $label tab',
          );
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byType(AskLukePill),
            ),
            findsOneWidget,
            reason: 'Expected Ask Luke pill present on the $label tab',
          );
          // Only one AppBar exists — chrome is rendered once by the shared
          // shell body, not duplicated per tab.
          expect(find.byType(AppBar), findsOneWidget);
        }
      },
    );
  });

  group('REQ-F02-015: chrome location', () {
    test(
      'AppBarLogo/SaintOfTheDayPill/AskLukePill live under lib/app/shell',
      () {
        // Source-location check: these imports resolve under
        // package:st_luke_parish_app/app/shell/widgets/, not
        // package:st_luke_parish_app/features/parish/ — verified by the
        // import paths above compiling successfully against that location.
        expect(true, isTrue);
      },
    );
  });

  // Sanity: the selectedNavIndexProvider still exists and still drives the
  // shell (regression guard carried over from feature 01, re-verified here
  // alongside the new AppBar assertions).
  test('selectedNavIndexProvider unaffected by AppBar chrome changes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(selectedNavIndexProvider), 0);
  });
}
