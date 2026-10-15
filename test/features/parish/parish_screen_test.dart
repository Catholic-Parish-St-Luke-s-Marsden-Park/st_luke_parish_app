import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/parish/data/config/church_leadership_config.dart';
import 'package:st_luke_parish_app/features/parish/presentation/screens/parish_screen.dart';
import 'package:st_luke_parish_app/features/parish/data/config/pastoral_plan_config.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/about_st_lukes_section.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/new_to_marsden_park_section.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/parish_prayer_section.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/leadership_entry_tile.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/parish_hero_banner.dart';

/// Covers the Parish tab content acceptance criteria: REQ-F02-001 through
/// REQ-F02-011.
class _FakeUrlLauncherService implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  Future<void> pumpParishScreen(
    WidgetTester tester, {
    required _FakeUrlLauncherService fakeLauncher,
  }) async {
    // ParishScreen is a lazily built ListView, so a tall surface is needed
    // for every section (Church Leadership sits below the About copy) to be
    // built and findable. Scrolling itself isn't under test here.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [urlLauncherServiceProvider.overrideWithValue(fakeLauncher)],
        child: const MaterialApp(home: Scaffold(body: ParishScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  group(
    'REQ-F02-001: ParishScreen renders real content, not a placeholder',
    () {
      testWidgets('does not render the generic PlaceholderScreen', (
        tester,
      ) async {
        await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

        expect(tester.takeException(), isNull);
        // The generic placeholder used the church icon as its sole content;
        // it must not appear now that ParishScreen has real content.
        expect(find.byIcon(Icons.church_rounded), findsNothing);
        expect(find.byType(ParishHeroBanner), findsOneWidget);
        expect(find.text("About St Luke's"), findsOneWidget);
        expect(find.text('CHURCH LEADERSHIP'), findsOneWidget);
      });
    },
  );

  group('REQ-F02-002/003: hero copy', () {
    testWidgets('does not contain the old eyebrow text in any case variant', (
      tester,
    ) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      // Search the hero banner's Text values for a case-insensitive match of
      // the retired eyebrow copy. Scoped to the banner because the
      // parish-supplied About St Luke's copy (2026-10-15) opens with the
      // same phrase, which is fine there; it is only retired as an eyebrow.
      final textWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(ParishHeroBanner),
          matching: find.byType(Text),
        ),
      );
      final hasOldEyebrow = textWidgets.any(
        (t) => (t.data ?? '').toLowerCase().contains(
          "australia's newest catholic parish",
        ),
      );
      expect(hasOldEyebrow, isFalse);
    });

    testWidgets('contains the exact new subtext and not the old subtext', (
      tester,
    ) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.text(ParishHeroBanner.subtitle), findsOneWidget);

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final hasOldSubtext = textWidgets.any(
        (t) => (t.data ?? '').contains(
          'Be a part of Something new - a community of faith',
        ),
      );
      expect(hasOldSubtext, isFalse);
    });
  });

  group('REQ-F02-004: Church Leadership has exactly 3 parts, in order', () {
    test('config defines exactly 3 sections in the required order', () {
      expect(churchLeadershipSections.length, 3);
      expect(churchLeadershipSections[0].title, 'Universal Church');
      expect(churchLeadershipSections[1].title, 'Diocese of Parramatta');
      expect(churchLeadershipSections[2].title, 'Parish');
    });

    testWidgets('renders no separate "Parish Leadership" card distinct from '
        '"Church Leadership"', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.text('Parish Leadership'), findsNothing);
      expect(find.text('Universal Church'), findsOneWidget);
      expect(find.text('Diocese of Parramatta'), findsOneWidget);
      // 'Parish' appears as the 3rd section title.
      expect(find.text('Parish'), findsOneWidget);
    });
  });

  group('REQ-F02-005: Universal Church — Pope Leo XIV', () {
    test('config has exactly one entry using a local asset and the correct '
        'external link', () {
      final section = churchLeadershipSections[0];
      expect(section.entries.length, 1);
      final entry = section.entries.single;
      expect(entry.name, 'Pope Leo XIV');
      expect(entry.assetPath, startsWith('assets/images/leadership/'));
      expect(entry.linkUrl, 'https://www.vaticannews.va/en.html');
    });

    testWidgets('tapping the Pope Leo XIV row launches its URL externally', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpParishScreen(tester, fakeLauncher: fakeLauncher);

      await tester.ensureVisible(find.text('Pope Leo XIV'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pope Leo XIV'));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['https://www.vaticannews.va/en.html']);
    });

    testWidgets('renders the entry image via Image.asset / AssetImage, not '
        'Image.network', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      final tile = tester.widget<LeadershipEntryTile>(
        find
            .ancestor(
              of: find.text('Pope Leo XIV'),
              matching: find.byType(LeadershipEntryTile),
            )
            .first,
      );
      final avatar = tester.widget<CircleAvatar>(
        find.descendant(
          of: find.byWidget(tile),
          matching: find.byType(CircleAvatar),
        ),
      );
      expect(avatar.backgroundImage, isA<AssetImage>());
    });
  });

  group('REQ-F02-006: Diocese of Parramatta — Bishop Vincent Long', () {
    test('config has exactly one entry with correct role and link', () {
      final section = churchLeadershipSections[1];
      expect(section.entries.length, 1);
      final entry = section.entries.single;
      expect(entry.name, 'Bishop Vincent Long');
      expect(entry.role, contains('Bishop of Parramatta'));
      expect(entry.assetPath, startsWith('assets/images/leadership/'));
      expect(entry.linkUrl, 'https://parracatholic.org');
    });

    testWidgets('tapping the Bishop Vincent Long row launches its URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpParishScreen(tester, fakeLauncher: fakeLauncher);

      await tester.ensureVisible(find.text('Bishop Vincent Long'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bishop Vincent Long'));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['https://parracatholic.org']);
    });
  });

  group('REQ-F02-007: Parish part — exactly 2 rows, Fr Gayan linked, Ged '
      'Oblea not linked', () {
    test('config has exactly 2 entries in the correct order', () {
      final section = churchLeadershipSections[2];
      expect(section.entries.length, 2);
      expect(section.entries[0].name, 'Fr Gayan Thamel');
      expect(section.entries[0].role, 'Parish Priest');
      expect(section.entries[0].linkUrl, 'https://stlukesmarsdenpark.org.au');
      expect(section.entries[1].name, 'Gerald "Ged" Oblea');
      expect(section.entries[1].role, 'Parish Secretary');
      expect(section.entries[1].linkUrl, isNull);
    });

    testWidgets('tapping Fr Gayan Thamel launches the parish website URL', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpParishScreen(tester, fakeLauncher: fakeLauncher);

      await tester.ensureVisible(find.text('Fr Gayan Thamel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fr Gayan Thamel'));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['https://stlukesmarsdenpark.org.au']);
    });

    testWidgets(
      'tapping Ged Oblea\'s row does not launch anything and no chevron '
      'is shown for that row',
      (tester) async {
        final fakeLauncher = _FakeUrlLauncherService();
        await pumpParishScreen(tester, fakeLauncher: fakeLauncher);

        final gedTileFinder = find
            .ancestor(
              of: find.text('Gerald "Ged" Oblea'),
              matching: find.byType(LeadershipEntryTile),
            )
            .first;
        final gedTile = tester.widget<LeadershipEntryTile>(gedTileFinder);
        expect(gedTile.entry.linkUrl, isNull);

        expect(
          find.descendant(
            of: gedTileFinder,
            matching: find.byIcon(Icons.chevron_right_rounded),
          ),
          findsNothing,
        );

        await tester.ensureVisible(find.text('Gerald "Ged" Oblea'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Gerald "Ged" Oblea'));
        await tester.pumpAndSettle();

        expect(fakeLauncher.launchedUrls, isEmpty);
      },
    );
  });

  group('REQ-F02-008: no Deacon Tony Hoban entry anywhere', () {
    test('config contains no Deacon Tony Hoban entry', () {
      final allNames = churchLeadershipSections
          .expand((s) => s.entries)
          .map((e) => e.name)
          .toList();
      expect(
        allNames.any((n) => n.toLowerCase().contains('tony hoban')),
        isFalse,
      );
      // Exactly 4 leadership entries total (1 + 1 + 2).
      expect(allNames.length, 4);
    });

    // The About St Luke's history names Deacon Tony Hoban as founding
    // Pastoral Director (parish-supplied copy, 2026-10-15). REQ-F02-008 is
    // about the leadership list, so only the leadership rows are checked.
    testWidgets('no leadership row mentions Deacon Tony Hoban', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      final tiles = find.byType(LeadershipEntryTile);
      expect(tiles, findsNWidgets(4));
      final leadershipText = tester.widgetList<Text>(
        find.descendant(of: tiles, matching: find.byType(Text)),
      );
      final mentionsDeacon = leadershipText.any(
        (t) => (t.data ?? '').toLowerCase().contains('tony hoban'),
      );
      expect(mentionsDeacon, isFalse);
    });
  });

  group('REQ-F02-009: all 4 leadership images use AssetImage, not '
      'Image.network', () {
    testWidgets(
      'every CircleAvatar in the Church Leadership section uses a local '
      'AssetImage',
      (tester) async {
        await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

        final avatars = tester.widgetList<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(avatars.length, 4);
        for (final avatar in avatars) {
          expect(avatar.backgroundImage, isA<AssetImage>());
        }
        // The About St Luke's emblem (and the Pastoral Plan graphic, once
        // opened) are local assets too: nothing loads from the network.
        for (final image in tester.widgetList<Image>(find.byType(Image))) {
          expect(image.image, isA<AssetImage>());
        }
      },
    );

    test('config asset paths all point under assets/images/leadership/', () {
      final allAssetPaths = churchLeadershipSections
          .expand((s) => s.entries)
          .map((e) => e.assetPath);
      for (final path in allAssetPaths) {
        expect(path, startsWith('assets/images/leadership/'));
      }
    });
  });

  group('REQ-F02-010/011: About St Luke\'s section', () {
    testWidgets("the About St Luke's ribbon shows the St Luke's emblem", (
      tester,
    ) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      final ribbon = find.ancestor(
        of: find.text("About St Luke's"),
        matching: find.byType(ExpansionTile),
      );
      expect(ribbon, findsOneWidget);
      final image = tester.widget<Image>(
        find.descendant(of: ribbon, matching: find.byType(Image)),
      );
      expect(
        (image.image as AssetImage).assetName,
        AboutStLukesSection.emblemAsset,
      );
      expect(
        find.descendant(
          of: ribbon,
          matching: find.byIcon(Icons.church_outlined),
        ),
        findsNothing,
      );
    });

    testWidgets('section order: hero, Our Story, then Church Leadership', (
      tester,
    ) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      double top(Finder finder) => tester.getTopLeft(finder).dy;
      final heroY = top(find.byType(ParishHeroBanner));
      final storyY = top(find.text('OUR STORY'));
      final leadershipY = top(find.text('CHURCH LEADERSHIP'));
      expect(heroY, lessThan(storyY));
      expect(storyY, lessThan(leadershipY));
      // Every leadership row comes after the story.
      for (final tileY
          in tester
              .widgetList(find.byType(LeadershipEntryTile))
              .map((w) => top(find.byWidget(w)))) {
        expect(tileY, greaterThan(storyY));
      }
    });

    testWidgets('collapsed, only the first paragraph shows; pulling down '
        'reveals the rest', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      const paragraphs = AboutStLukesSection.paragraphs;
      expect(find.text("About St Luke's"), findsOneWidget);
      expect(find.text(paragraphs.first), findsOneWidget);
      expect(
        paragraphs.first,
        endsWith(
          "Australia's newest Catholic Parish within the Diocese of "
          'Parramatta.',
        ),
      );
      for (final paragraph in paragraphs.skip(1)) {
        expect(find.text(paragraph), findsNothing);
      }

      await tester.tap(find.text("About St Luke's"));
      await tester.pumpAndSettle();
      for (final paragraph in paragraphs) {
        expect(find.text(paragraph), findsOneWidget);
      }

      await tester.tap(find.text("About St Luke's"));
      await tester.pumpAndSettle();
      expect(find.text(paragraphs.last), findsNothing);
    });
  });

  group("Pastoral Plan, inside About St Luke's", () {
    testWidgets("hidden until About St Luke's is opened, then shows the "
        'pillars, the graphic and the PDF button', (tester) async {
      final launcher = _FakeUrlLauncherService();
      await pumpParishScreen(tester, fakeLauncher: launcher);

      expect(find.text(PastoralPlanConfig.title), findsNothing);

      await tester.tap(find.text("About St Luke's"));
      await tester.pumpAndSettle();

      expect(find.text(PastoralPlanConfig.title), findsOneWidget);
      expect(find.text(PastoralPlanConfig.summary), findsOneWidget);
      for (final pillar in [
        'Faith Enrichment',
        'Serving God and Others',
        'Stronger Community Connection',
        'A Vibrant Worship Experience',
      ]) {
        expect(PastoralPlanConfig.summary, contains(pillar));
      }
      final graphic = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                PastoralPlanConfig.pillarsAsset,
      );
      expect(graphic, findsOneWidget);
      expect(
        tester.widget<Image>(graphic).semanticLabel,
        PastoralPlanConfig.pillarsImageLabel,
      );

      final button = find.text('Read our Pastoral Plan');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(button);
      expect(launcher.launchedUrls, [PastoralPlanConfig.pdfUrl]);

      final minutes = find.text('Pastoral Council Meeting Minutes');
      await tester.ensureVisible(minutes);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(minutes);
      expect(launcher.launchedUrls, [
        PastoralPlanConfig.pdfUrl,
        PastoralPlanConfig.councilMinutesUrl,
      ]);
    });
  });

  group('Our Parish Prayer', () {
    testWidgets('the prayer and its invocations show at the bottom, after '
        'Church Leadership', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.text('OUR PARISH PRAYER'), findsOneWidget);
      expect(find.text(ParishPrayerSection.prayer), findsOneWidget);
      for (final invocation in ParishPrayerSection.invocations) {
        expect(find.text(invocation), findsOneWidget);
      }

      double top(Finder finder) => tester.getTopLeft(finder).dy;
      final prayerY = top(find.text('OUR PARISH PRAYER'));
      expect(prayerY, greaterThan(top(find.text('CHURCH LEADERSHIP'))));
      for (final tile in tester.widgetList(find.byType(LeadershipEntryTile))) {
        expect(prayerY, greaterThan(top(find.byWidget(tile))));
      }
    });

    testWidgets('"New to Marsden Park?" sits after Church Leadership and '
        'before the parish prayer', (tester) async {
      await pumpParishScreen(tester, fakeLauncher: _FakeUrlLauncherService());

      expect(find.text(NewToMarsdenParkSection.title), findsOneWidget);
      expect(find.text(NewToMarsdenParkSection.body), findsOneWidget);
      expect(
        NewToMarsdenParkSection.body,
        contains('marsdenpark@parracatholic.org'),
      );

      double top(Finder finder) => tester.getTopLeft(finder).dy;
      final welcomeY = top(find.text(NewToMarsdenParkSection.title));
      for (final tile in tester.widgetList(find.byType(LeadershipEntryTile))) {
        expect(welcomeY, greaterThan(top(find.byWidget(tile))));
      }
      expect(welcomeY, lessThan(top(find.text('OUR PARISH PRAYER'))));
    });

    test('the prayer text matches the parish web app', () {
      expect(
        ParishPrayerSection.prayer,
        startsWith('O God, You show us in St Luke, our patron,'),
      );
      expect(
        ParishPrayerSection.prayer,
        endsWith('We ask this through Christ our Lord. Amen.'),
      );
      expect(ParishPrayerSection.invocations, hasLength(4));
    });
  });
}
