import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/events/domain/entities/parish_event.dart';
import 'package:st_luke_parish_app/features/events/domain/repositories/events_repository.dart';
import 'package:st_luke_parish_app/features/events/presentation/providers/events_provider.dart';
import 'package:st_luke_parish_app/features/news/data/config/static_announcements_config.dart';
import 'package:st_luke_parish_app/features/news/domain/entities/bulletin.dart';
import 'package:st_luke_parish_app/features/news/domain/failures/bulletins_failure.dart';
import 'package:st_luke_parish_app/features/news/domain/repositories/bulletins_repository.dart';
import 'package:st_luke_parish_app/features/news/presentation/providers/bulletins_provider.dart';
import 'package:st_luke_parish_app/features/news/presentation/screens/news_screen.dart';
import 'package:st_luke_parish_app/features/news/presentation/widgets/bulletin_list_tile.dart';

/// Covers the News tab acceptance criteria: REQ-F05-001..038, exercised
/// through the full `NewsScreen` widget tree with a fake `BulletinsRepository`
/// override (never the real network datasource in widget tests).
class _FakeUrlLauncherService implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

class _FakeBulletinsRepository implements BulletinsRepository {
  _FakeBulletinsRepository.returning(this._result) : _error = null;
  _FakeBulletinsRepository.throwing(Object error)
    : _result = null,
      _error = error;

  final List<Bulletin>? _result;
  final Object? _error;

  @override
  Future<List<Bulletin>> getBulletins() async {
    if (_error != null) throw _error;
    return _result!;
  }
}

Bulletin _bulletin(String title, {String? pdfUrl}) => Bulletin(
  title: title,
  pageUrl: 'https://stlukesmarsdenpark.org.au/$title',
  pdfUrl: pdfUrl ?? 'https://stlukesmarsdenpark.org.au/$title.pdf',
  date: DateTime.utc(2026, 8, 29),
  displayDate: '29 August 2026',
);

void main() {
  Future<_FakeUrlLauncherService> pumpNewsScreen(
    WidgetTester tester, {
    required BulletinsRepository fakeRepository,
  }) async {
    // The full screen (hero + 3 sections + up to 6 bulletin rows) is taller
    // than the default 800x600 test surface — use a tall surface so every
    // row is built and tappable without needing to scroll mid-test (same
    // pattern as contact_screen_test.dart/masses_screen_test.dart).
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeLauncher = _FakeUrlLauncherService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bulletinsRepositoryProvider.overrideWithValue(fakeRepository),
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository.returning(const []),
          ),
          urlLauncherServiceProvider.overrideWithValue(fakeLauncher),
        ],
        child: const MaterialApp(home: Scaffold(body: NewsScreen())),
      ),
    );
    await tester.pumpAndSettle();
    return fakeLauncher;
  }

  group('REQ-F05-031: 3 sections render, in order, no PlaceholderScreen', () {
    testWidgets('renders "Latest Bulletins", "Parish News", "Submit a '
        'Prayer Request" in order', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('News & Bulletins'), findsOneWidget);

      const titles = [
        'Latest Bulletins',
        'Parish News',
        'Submit a Prayer Request',
      ];
      for (final title in titles) {
        expect(find.text(title), findsOneWidget);
      }
      final positions = titles
          .map((t) => tester.getTopLeft(find.text(t)).dy)
          .toList();
      expect(positions, orderedEquals(List.of(positions)..sort()));
    });
  });

  group('REQ-F05-016: loading state', () {
    testWidgets('shows a loading indicator before the future resolves', (
      tester,
    ) async {
      // Use a never-completing future to observe the loading state.
      final pendingRepo = _PendingBulletinsRepository();
      final pendingEventsRepo = _PendingEventsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bulletinsRepositoryProvider.overrideWithValue(pendingRepo),
            eventsRepositoryProvider.overrideWithValue(pendingEventsRepo),
            urlLauncherServiceProvider.overrideWithValue(
              _FakeUrlLauncherService(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: NewsScreen())),
        ),
      );
      await tester.pump();

      // Both sections' own spinners are expected while both providers are
      // still loading (REQ-F05-016, REQ-F08-014).
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      expect(find.text('Loading the latest bulletins…'), findsOneWidget);
    });
  });

  group('REQ-F05-017: success state renders title/date/pill/download link', () {
    testWidgets('renders bulletin title, date, LATEST pill for the first '
        'item, and "Download PDF ↗"', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
        ]),
      );

      expect(find.text('30th August 2026'), findsOneWidget);
      expect(find.text('29 August 2026'), findsOneWidget);
      expect(find.text('LATEST'), findsOneWidget);
      expect(find.text('Download PDF ↗'), findsOneWidget);
    });
  });

  group('REQ-F05-007: LATEST/PREVIOUS pill labels', () {
    testWidgets('first item is LATEST, the rest are PREVIOUS', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('First'),
          _bulletin('Second'),
          _bulletin('Third'),
        ]),
      );

      expect(find.text('LATEST'), findsOneWidget);
      expect(find.text('PREVIOUS'), findsNWidgets(2));
      expect(find.byType(BulletinListTile), findsNWidgets(3));
    });
  });

  group('REQ-F05-022: tapping "Download PDF ↗" launches the bulletin URL', () {
    testWidgets('launches the bulletin pdfUrl externally', (tester) async {
      final fakeLauncher = await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026', pdfUrl: 'https://example.org/x.pdf'),
        ]),
      );

      await tester.tap(find.text('Download PDF ↗'));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, ['https://example.org/x.pdf']);
    });
  });

  group('REQ-F05-018: empty-result state with fallback link', () {
    testWidgets('shows a distinct empty message and a tappable fallback '
        'link that launches the bulletins archive URL', (tester) async {
      final fakeLauncher = await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([]),
      );

      expect(
        find.text('No bulletins are available right now.'),
        findsOneWidget,
      );
      final fallbackFinder = find.textContaining(
        'View bulletins on the parish website',
      );
      expect(fallbackFinder, findsOneWidget);

      await tester.tap(fallbackFinder);
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, [
        'https://stlukesmarsdenpark.org.au/category/bulletins/',
      ]);
    });
  });

  group('REQ-F05-019/020: parsing/network failure states with fallback '
      'link, no raw exception text', () {
    testWidgets('a parsing failure shows a friendly message and the '
        'fallback link, tappable', (tester) async {
      final fakeLauncher = await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.throwing(
          const BulletinsParsingFailure('malformed xml detail'),
        ),
      );

      expect(find.textContaining('malformed xml detail'), findsNothing);
      expect(
        find.text("Couldn't load the latest bulletins right now."),
        findsOneWidget,
      );
      final fallbackFinder = find.textContaining(
        'View bulletins on the parish website',
      );
      expect(fallbackFinder, findsOneWidget);

      await tester.tap(fallbackFinder);
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, [
        'https://stlukesmarsdenpark.org.au/category/bulletins/',
      ]);
    });

    testWidgets('a network failure shows a friendly, distinguishable '
        'message and the fallback link', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.throwing(
          const BulletinsNetworkFailure('connection refused'),
        ),
      );

      expect(find.textContaining('connection refused'), findsNothing);
      expect(
        find.textContaining("Couldn't connect to load the latest bulletins"),
        findsOneWidget,
      );
      expect(
        find.textContaining('View bulletins on the parish website'),
        findsOneWidget,
      );
    });
  });

  group('REQ-F05-023/024/025: the static announcement, exact content', () {
    testWidgets('renders the announcement with exact badge/title/body/date; '
        '"New to Marsden Park?" has moved to the Parish tab', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
        ]),
      );

      expect(staticAnnouncements, hasLength(1));

      expect(find.text('MILESTONE'), findsOneWidget);
      expect(find.text('New Parish Building Now Open'), findsOneWidget);
      expect(
        find.text(
          'Our purpose-built parish building was opened and blessed on '
          'the Feast of St Luke in October 2025. All Masses and parish '
          'events are now held at the corner of Frontier Avenue and '
          'Northbourne Drive.',
        ),
        findsOneWidget,
      );
      expect(find.text('October 2025'), findsOneWidget);

      // Moved to the Parish tab (parish request, 2026-10-16).
      expect(find.text('NEW TO THE AREA?'), findsNothing);
      expect(find.text('New to Marsden Park?'), findsNothing);
      expect(find.text('Ongoing'), findsNothing);

      // REQ-F05-025: the reference app's third entry must not appear.
      expect(find.text('Sacramental Programme 2026'), findsNothing);
    });
  });

  group('REQ-F05-026/027/028: Prayer Intentions card content and CTA', () {
    testWidgets('renders the quote, body, and CTA; tapping the CTA launches '
        'the prayer-requests URL', (tester) async {
      final fakeLauncher = await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
        ]),
      );

      expect(
        find.text(
          '"The prayer of a righteous person has great power. — James 5:16"',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Our youth and prayer groups are willing to support you in '
          'prayer. Submit your intentions on our website.',
        ),
        findsOneWidget,
      );

      final ctaFinder = find.text('Submit Prayer Request ↗');
      expect(ctaFinder, findsOneWidget);

      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, [
        'https://stlukesmarsdenpark.org.au/#prayerrequests',
      ]);
    });
  });

  group('REQ-F05-030: no Icon widget and no emoji glyph anywhere', () {
    testWidgets('no Icon widget is rendered', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
          _bulletin('23rd August 2026'),
        ]),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('no rendered Text contains an emoji glyph', (tester) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([
          _bulletin('30th August 2026'),
        ]),
      );

      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
        unicode: true,
      );
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final hasEmoji = textWidgets.any(
        (t) => emojiPattern.hasMatch(t.data ?? ''),
      );
      expect(hasEmoji, isFalse);
    });

    testWidgets('an empty/error bulletins state also has no icon/emoji', (
      tester,
    ) async {
      await pumpNewsScreen(
        tester,
        fakeRepository: _FakeBulletinsRepository.returning([]),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('REQ-F05-036: reflows without overflow at increased text scale and '
      'across screen sizes', () {
    const phoneSize = Size(390, 844);
    const smallPhoneSize = Size(360, 690);
    const tabletSize = Size(1024, 1366);

    Future<void> expectNoOverflowAt(
      WidgetTester tester,
      Size size,
      TextScaler textScaler,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bulletinsRepositoryProvider.overrideWithValue(
              _FakeBulletinsRepository.returning([
                _bulletin(
                  'A very long bulletin title that could plausibly wrap '
                  'across multiple lines on a small screen',
                ),
                _bulletin('23rd August 2026'),
              ]),
            ),
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning(const []),
            ),
            urlLauncherServiceProvider.overrideWithValue(
              _FakeUrlLauncherService(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: const Scaffold(body: NewsScreen()),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'Expected no overflow/clipping exceptions at size $size, '
            'textScaler $textScaler',
      );
    }

    for (final size in [smallPhoneSize, phoneSize, tabletSize]) {
      testWidgets('no overflow at $size, default text scale', (tester) async {
        await expectNoOverflowAt(tester, size, TextScaler.noScaling);
      });

      testWidgets('no overflow at $size, TextScaler.linear(1.5)', (
        tester,
      ) async {
        await expectNoOverflowAt(tester, size, TextScaler.linear(1.5));
      });

      testWidgets('no overflow at $size, TextScaler.linear(2.0)', (
        tester,
      ) async {
        await expectNoOverflowAt(tester, size, TextScaler.linear(2.0));
      });
    }

    testWidgets('empty/fallback-link state reflows without overflow at '
        'increased text scale', (tester) async {
      tester.view.physicalSize = smallPhoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bulletinsRepositoryProvider.overrideWithValue(
              _FakeBulletinsRepository.returning([]),
            ),
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning(const []),
            ),
            urlLauncherServiceProvider.overrideWithValue(
              _FakeUrlLauncherService(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(2.0)),
                  child: const Scaffold(body: NewsScreen()),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

/// A [BulletinsRepository] whose future never resolves, for observing the
/// loading state in isolation.
class _PendingBulletinsRepository implements BulletinsRepository {
  @override
  Future<List<Bulletin>> getBulletins() => Completer<List<Bulletin>>().future;
}

/// News-screen widget tests never make a real network call for Events
/// either (same rule as bulletins, see this file's top doc comment) — this
/// feature's own tests live under test/features/events/; these two fakes
/// exist only so NewsScreen's widget tree has something deterministic to
/// read from the Events section while these pre-existing News tests focus
/// on bulletins.
class _FakeEventsRepository implements EventsRepository {
  _FakeEventsRepository.returning(this._result);

  final List<ParishEvent> _result;

  @override
  Future<List<ParishEvent>> getUpcomingEvents() async => _result;
}

/// An [EventsRepository] whose future never resolves, for observing the
/// News screen's loading state in isolation (same precedent as
/// [_PendingBulletinsRepository]) — only used with tester.pump(), never
/// tester.pumpAndSettle(), which would hang against a future that never
/// completes.
class _PendingEventsRepository implements EventsRepository {
  @override
  Future<List<ParishEvent>> getUpcomingEvents() =>
      Completer<List<ParishEvent>>().future;
}
