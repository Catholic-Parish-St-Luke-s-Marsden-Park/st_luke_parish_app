import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/constants/external_links.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/resources/data/config/static_resources_config.dart';
import 'package:st_luke_parish_app/features/resources/domain/entities/monthly_reflection.dart';
import 'package:st_luke_parish_app/features/resources/domain/entities/resource_link.dart';
import 'package:st_luke_parish_app/features/resources/domain/failures/reflections_failure.dart';
import 'package:st_luke_parish_app/features/resources/presentation/providers/reflections_provider.dart';
import 'package:st_luke_parish_app/features/resources/presentation/screens/resources_screen.dart';

class _FakeUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

final _october = MonthlyReflection(
  label: 'October 2026',
  month: DateTime(2026, 10),
  url: 'https://www.risenlordcommunity.com/_files/ugd/oct.pdf',
);

void main() {
  late _FakeUrlLauncher launcher;
  late List<AppTab> openedTabs;

  Future<void> pumpResources(
    WidgetTester tester, {
    Future<MonthlyReflection> Function()? reflection,
    Size size = const Size(800, 3200),
    TextScaler textScaler = TextScaler.noScaling,
    bool faithFormation = false,
  }) async {
    launcher = _FakeUrlLauncher();
    openedTabs = [];
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlLauncherServiceProvider.overrideWithValue(launcher),
          latestReflectionProvider.overrideWith(
            (ref) =>
                reflection?.call() ??
                Future.error(const ReflectionsNetworkFailure('offline')),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: faithFormation
                  ? ResourcesScreen(
                      title: 'Faith Formation',
                      groups: faithFormationGroups,
                      onOpenTab: openedTabs.add,
                    )
                  : ResourcesScreen(onOpenTab: openedTabs.add),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapRow(WidgetTester tester, String title) async {
    final row = find.text(title);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  testWidgets('Resources shows its three groups, in order, with every link; '
      'Faith Formation has moved to its own page', (tester) async {
    await pumpResources(tester);

    expect(find.widgetWithText(AppBar, 'Resources'), findsOneWidget);
    const groups = [
      'Parish Resources',
      'Universal & Local Church',
      'Scripture & Readings',
    ];
    expect(resourceGroups.map((g) => g.title), groups);
    // Renamed from "Bible & Liturgy", with no caption under it.
    expect(find.text('Bible & Liturgy'), findsNothing);
    expect(find.text('SCRIPTURE & READINGS'), findsNothing);
    final tops = [
      for (final title in groups) tester.getTopLeft(find.text(title)).dy,
    ];
    expect(tops, orderedEquals(List.of(tops)..sort()));
    for (final link in resourceGroups.expand((g) => g.links)) {
      expect(find.text(link.title), findsOneWidget, reason: link.title);
    }
    expect(find.text('Faith Formation'), findsNothing);
    expect(find.text('FORMED'), findsNothing);
  });

  testWidgets(
    'the Faith Formation page shows its five links, CHARIS just before On Our Knees',
    (tester) async {
      await pumpResources(tester, faithFormation: true);

      expect(find.widgetWithText(AppBar, 'Faith Formation'), findsOneWidget);
      final links = faithFormationGroups.expand((g) => g.links).toList();
      expect(links, hasLength(5));
      expect(links.map((l) => l.title), [
        'FORMED',
        'Word on Fire',
        'Catholic Prayers',
        'CHARIS',
        'On Our Knees',
      ]);
      for (final gone in [
        'Encounter Ministries',
        'Catholic Sprout',
        'Saints Directory',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      for (final link in links) {
        expect(find.text(link.title), findsOneWidget, reason: link.title);
      }
      expect(find.text('Vatican News'), findsNothing);
    },
  );

  testWidgets('"Universal & Local Church" has only Catholic Church '
      'Australia and Vatican News, with no caption', (tester) async {
    await pumpResources(tester);

    final group = resourceGroups.singleWhere(
      (g) => g.title == 'Universal & Local Church',
    );
    expect(group.links.map((l) => l.title), [
      'Vatican News',
      'Catholic Church Australia',
    ]);
    expect(group.subtitle, isNull);
    for (final gone in [
      'Vatican & Diocese',
      'OFFICIAL CHURCH',
      'Vatican Website',
      'Diocese of Parramatta',
    ]) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
  });

  test('Scripture & Readings: Daily Mass Readings (USCCB), then Catholic '
      'Bible Readings (Bible Gateway); no Universalis', () {
    final group = resourceGroups.singleWhere(
      (g) => g.title == 'Scripture & Readings',
    );
    expect(
      [
        for (final link in group.links)
          (link.title, (link.destination as WebDestination).url),
      ],
      [
        ('Daily Mass Readings', 'https://bible.usccb.org'),
        ('Catholic Bible Readings', 'https://www.biblegateway.com/'),
      ],
    );
  });

  testWidgets('a web link opens its site in the browser', (tester) async {
    await pumpResources(tester);

    await tapRow(tester, 'Vatican News');
    await tapRow(tester, 'Daily Mass Readings');

    expect(launcher.launchedUrls, [
      'https://www.vaticannews.va/en.html',
      'https://bible.usccb.org',
    ]);
  });

  testWidgets('Prayer Requests opens the parish prayer-request page', (
    tester,
  ) async {
    await pumpResources(tester);

    await tapRow(tester, 'Prayer Requests');

    expect(launcher.launchedUrls, [ExternalLinks.prayerRequests]);
  });

  testWidgets('Weekly Bulletins and Donate Online switch to the app tabs '
      'instead of opening the website', (tester) async {
    await pumpResources(tester);

    await tapRow(tester, 'Weekly Bulletins');
    await tapRow(tester, 'Donate Online');

    expect(openedTabs, [AppTab.news, AppTab.donate]);
    expect(launcher.launchedUrls, isEmpty);
  });

  testWidgets("Daily Readings & Reflections opens this month's booklet and "
      'names the month', (tester) async {
    await pumpResources(
      tester,
      faithFormation: true,
      reflection: () async => _october,
    );

    expect(find.text('On Our Knees (October 2026 Edition)'), findsOneWidget);
    expect(find.text('Daily Reading & Reflections'), findsOneWidget);
    await tapRow(tester, 'On Our Knees (October 2026 Edition)');

    expect(launcher.launchedUrls, [_october.url]);
  });

  testWidgets('if the booklet list cannot be read, Daily Readings & '
      'Reflections opens the page listing every month', (tester) async {
    await pumpResources(tester, faithFormation: true);

    await tapRow(tester, 'On Our Knees');

    expect(launcher.launchedUrls, [ExternalLinks.dailyReflectionsPage]);
  });

  for (final faith in [false, true]) {
    final page = faith ? 'Faith Formation' : 'Resources';
    final groups = faith ? faithFormationGroups : resourceGroups;

    testWidgets('$page: every row is at least 48dp tall', (tester) async {
      await pumpResources(tester, faithFormation: faith);

      for (final link in groups.expand((g) => g.links)) {
        final row = find.ancestor(
          of: find.text(link.title),
          matching: find.byType(InkWell),
        );
        await tester.ensureVisible(row.first);
        expect(
          tester.getSize(row.first).height,
          greaterThanOrEqualTo(48),
          reason: link.title,
        );
      }
    });

    for (final size in const [Size(360, 690), Size(390, 844)]) {
      for (final scale in const [1.0, 1.5, 2.0]) {
        testWidgets('$page: no overflow at $size, text x$scale', (
          tester,
        ) async {
          await pumpResources(
            tester,
            faithFormation: faith,
            size: size,
            textScaler: TextScaler.linear(scale),
            reflection: () async => _october,
          );
          expect(tester.takeException(), isNull);
          // Scroll the whole list so every card is laid out.
          await tester.drag(find.byType(ListView), const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
