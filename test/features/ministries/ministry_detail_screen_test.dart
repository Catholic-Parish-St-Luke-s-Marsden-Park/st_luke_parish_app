import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/ministries/data/config/static_ministries_config.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministry_detail_screen.dart';

/// Covers the ministry detail screen acceptance criteria: REQ-F03-005..009.
class _FakeUrlLauncherService implements UrlLauncherService {
  _FakeUrlLauncherService({this.launchResult = true});

  final bool launchResult;
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return launchResult;
  }
}

void main() {
  final music = staticMinistries.firstWhere((m) => m.id == 'music');
  final sacramental = staticMinistries.firstWhere((m) => m.id == 'sacramental');

  Future<void> pumpDetail(
    WidgetTester tester, {
    required String ministryId,
    required _FakeUrlLauncherService fakeLauncher,
  }) async {
    // The detail screen's CustomScrollView content (hero + stats + About +
    // leader row + How to Join + CTA) is taller than the default 800x600
    // test surface — use a tall surface so every section is built and
    // findable/tappable without needing to scroll mid-test.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [urlLauncherServiceProvider.overrideWithValue(fakeLauncher)],
        child: MaterialApp(home: MinistryDetailScreen(ministryId: ministryId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('REQ-F03-005: hero does not render the emoji', () {
    testWidgets('no Text widget on the detail screen renders the emoji', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        ministryId: music.id,
        fakeLauncher: _FakeUrlLauncherService(),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(music.name), findsOneWidget);
      expect(find.text(music.tagline), findsOneWidget);

      final renderedTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toSet();
      expect(renderedTexts, isNot(contains(music.emoji)));
      for (final text in renderedTexts) {
        expect(text.contains(music.emoji), isFalse);
      }
    });
  });

  group('REQ-F03-006: detail screen renders When/Where/Open-to, About, '
      'leader row, and How to Join', () {
    testWidgets('renders time/location/open/about/leader/joinInfo', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        ministryId: music.id,
        fakeLauncher: _FakeUrlLauncherService(),
      );

      // _StatChip renders its label uppercased (e.g. "WHEN").
      expect(find.text('WHEN'), findsOneWidget);
      expect(find.text('WHERE'), findsOneWidget);
      expect(find.text('OPEN TO'), findsOneWidget);
      expect(find.text(music.time), findsOneWidget);
      expect(find.text(music.location), findsOneWidget);
      expect(find.text(music.open), findsOneWidget);

      expect(find.text('ABOUT THIS MINISTRY'), findsOneWidget);
      expect(find.text(music.about), findsOneWidget);

      expect(find.text('MINISTRY LEAD / CONTACT'), findsOneWidget);
      expect(find.text(music.leaderInitials), findsOneWidget);
      expect(find.text(music.leaderName), findsOneWidget);
      expect(find.text(music.leaderRole), findsOneWidget);

      expect(find.text('HOW TO JOIN'), findsOneWidget);
      expect(find.text(music.joinInfo), findsOneWidget);
    });
  });

  group('REQ-F03-007: CTA button launches mailto:{ctaEmail}', () {
    testWidgets('tapping the CTA button launches mailto with ctaEmail', (
      tester,
    ) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpDetail(
        tester,
        ministryId: music.id,
        fakeLauncher: fakeLauncher,
      );

      expect(find.text(music.ctaLabel), findsOneWidget);
      await tester.tap(find.text(music.ctaLabel));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['mailto:${music.ctaEmail}']);
    });

    testWidgets(
      'a failed/unavailable launch (e.g. no mail app installed) does not '
      'throw and is surfaced via the fake launcher returning false',
      (tester) async {
        final fakeLauncher = _FakeUrlLauncherService(launchResult: false);
        await pumpDetail(
          tester,
          ministryId: music.id,
          fakeLauncher: fakeLauncher,
        );

        await tester.tap(find.text(music.ctaLabel));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(fakeLauncher.launchedUrls, ['mailto:${music.ctaEmail}']);
      },
    );
  });

  group('REQ-F03-008: sacramental ministry uses the distinct '
      'sacraments@ ctaEmail', () {
    test('sacramental ctaEmail is the sacraments@ address', () {
      expect(
        sacramental.ctaEmail,
        'sacraments@stlukesmarsdenpark.org.au?subject=Sacramental '
        'Programme 2026',
      );
    });

    test('all other 15 ministries use the marsdenpark@parracatholic.org '
        'address pattern', () {
      final others = staticMinistries.where((m) => m.id != 'sacramental');
      expect(others.length, 15);
      for (final ministry in others) {
        expect(
          ministry.ctaEmail,
          startsWith('marsdenpark@parracatholic.org?subject='),
        );
      }
    });

    testWidgets('tapping the sacramental CTA launches the sacraments@ '
        'mailto', (tester) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpDetail(
        tester,
        ministryId: sacramental.id,
        fakeLauncher: fakeLauncher,
      );

      await tester.tap(find.text(sacramental.ctaLabel));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['mailto:${sacramental.ctaEmail}']);
    });
  });

  group('REQ-F03-009: Ministry entity is typed/immutable with a const '
      'constructor', () {
    test('const constructor compiles (this file itself proves it)', () {
      const ministry = Ministry(
        id: 'x',
        category: 'x',
        emoji: 'x',
        name: 'x',
        membersLine: 'x',
        dayLine: 'x',
        tagline: 'x',
        time: 'x',
        location: 'x',
        open: 'x',
        about: 'x',
        leaderName: 'x',
        leaderRole: 'x',
        leaderInitials: 'x',
        joinInfo: 'x',
        ctaLabel: 'x',
        ctaEmail: 'x',
      );
      expect(ministry.id, 'x');
    });
  });
}
