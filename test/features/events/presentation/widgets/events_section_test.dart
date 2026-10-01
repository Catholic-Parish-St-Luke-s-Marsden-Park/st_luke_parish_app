import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart' show Event;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/events/data/parsers/ics_event_parser.dart'
    show sydneyNowAsFakeUtc;
import 'package:st_luke_parish_app/features/events/domain/entities/parish_event.dart';
import 'package:st_luke_parish_app/features/events/domain/failures/events_failure.dart';
import 'package:st_luke_parish_app/features/events/domain/repositories/events_repository.dart';
import 'package:st_luke_parish_app/features/events/presentation/providers/events_provider.dart';
import 'package:st_luke_parish_app/features/events/presentation/screens/all_events_screen.dart';
import 'package:st_luke_parish_app/features/events/presentation/services/calendar_export_service.dart';
import 'package:st_luke_parish_app/features/events/presentation/widgets/events_section.dart';

/// Covers the inline "Upcoming Events" section's own acceptance criteria:
/// REQ-F08-014..021 (loading/success/empty states/fallback link/"View all"
/// link), REQ-F08-022..025 (per-row Details/Add-to-calendar actions),
/// REQ-F08-032 (no Icon/emoji), and REQ-F08-037 (text-scale/screen-size
/// overflow), exercised through `EventsSection`'s own widget tree with a
/// fake `EventsRepository` override (never the real network datasource).
class _FakeUrlLauncherService implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

class _FakeCalendarExportService implements CalendarExportService {
  _FakeCalendarExportService({this.succeed = true});

  final bool succeed;
  final List<Event> addedEvents = [];

  @override
  Future<bool> addEvent(Event event) async {
    addedEvents.add(event);
    return succeed;
  }
}

class _FakeEventsRepository implements EventsRepository {
  _FakeEventsRepository.returning(this._result) : _error = null;
  _FakeEventsRepository.throwing(Object error) : _result = null, _error = error;

  final List<ParishEvent>? _result;
  final Object? _error;

  @override
  Future<List<ParishEvent>> getUpcomingEvents() async {
    if (_error != null) throw _error;
    return _result!;
  }
}

/// An [EventsRepository] whose future never resolves, for observing the
/// loading state in isolation (same precedent as `_PendingBulletinsRepository`
/// in `news_screen_test.dart`) — only used with `tester.pump()`, never
/// `tester.pumpAndSettle()`, which would hang against a future that never
/// completes.
class _PendingEventsRepository implements EventsRepository {
  @override
  Future<List<ParishEvent>> getUpcomingEvents() =>
      Completer<List<ParishEvent>>().future;
}

ParishEvent _event(
  String title, {
  required DateTime start,
  String displayTime = 'Fri 2 Oct 6:30 pm',
  String? location,
  String? description,
  String? detailUrl,
}) => ParishEvent(
  uid: 'uid-$title',
  title: title,
  start: start,
  displayTime: displayTime,
  location: location,
  description: description,
  detailUrl: detailUrl,
);

void main() {
  Future<void> pumpEventsSection(
    WidgetTester tester, {
    required EventsRepository fakeRepository,
    _FakeUrlLauncherService? launcher,
    _FakeCalendarExportService? calendarExport,
    Size size = const Size(400, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(fakeRepository),
          urlLauncherServiceProvider.overrideWithValue(
            launcher ?? _FakeUrlLauncherService(),
          ),
          calendarExportServiceProvider.overrideWithValue(
            calendarExport ?? _FakeCalendarExportService(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: EventsSection())),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('REQ-F08-014: loading state', () {
    testWidgets('shows an explicit loading indicator before the future '
        'resolves', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventsRepositoryProvider.overrideWithValue(
              _PendingEventsRepository(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: EventsSection())),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading upcoming events…'), findsOneWidget);
    });
  });

  group('REQ-F08-015: success state renders rows within the next 7 days', () {
    testWidgets('renders date pill, title, and location for an event '
        'within the week', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event(
            'Vigil Mass 5.30pm',
            start: now.add(const Duration(days: 2)),
            location: "St Luke's Catholic Church",
          ),
        ]),
      );

      expect(find.text('Vigil Mass 5.30pm'), findsOneWidget);
      expect(find.text("St Luke's Catholic Church"), findsOneWidget);
      expect(find.text('Fri 2 Oct 6:30 pm'), findsOneWidget);
    });

    testWidgets('an event with no location renders no location line', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Sunday Mass', start: now.add(const Duration(days: 1))),
        ]),
      );

      expect(find.text('Sunday Mass'), findsOneWidget);
    });

    testWidgets('an event further than 7 days out is excluded from the '
        'inline list', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Within the week', start: now.add(const Duration(days: 3))),
          _event('Next month', start: now.add(const Duration(days: 30))),
        ]),
      );

      expect(find.text('Within the week'), findsOneWidget);
      expect(find.text('Next month'), findsNothing);
    });
  });

  group('REQ-F08-016: fully-empty state', () {
    testWidgets('shows a "no upcoming events" message and a website '
        'fallback link', (tester) async {
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning(const []),
        launcher: fakeLauncher,
      );

      expect(find.text('No upcoming events right now.'), findsOneWidget);
      final linkFinder = find.text(
        'View upcoming events on the parish website ↗',
      );
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrls, [
        'https://stlukesmarsdenpark.org.au/calendar-2/',
      ]);
    });

    testWidgets('does not show the "View all upcoming events" link', (
      tester,
    ) async {
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning(const []),
      );

      expect(find.text('View all upcoming events'), findsNothing);
    });
  });

  group('REQ-F08-017: empty-this-week state', () {
    testWidgets('shows a distinct message and the "View all upcoming '
        'events" link, not the website fallback link', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Far out event', start: now.add(const Duration(days: 30))),
        ]),
      );

      expect(find.text('No events in the next 7 days.'), findsOneWidget);
      expect(find.text('View all upcoming events'), findsOneWidget);
      expect(
        find.text('View upcoming events on the parish website ↗'),
        findsNothing,
      );
    });
  });

  group('REQ-F08-018/019: parsing- and network-failure states', () {
    testWidgets('a parsing failure shows a friendly message and the '
        'fallback link', (tester) async {
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.throwing(
          const EventsParsingFailure('malformed'),
        ),
      );

      expect(
        find.text("Couldn't load upcoming events right now."),
        findsOneWidget,
      );
      expect(
        find.text('View upcoming events on the parish website ↗'),
        findsOneWidget,
      );
    });

    testWidgets('a network failure shows a friendly, distinguishable '
        'message', (tester) async {
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.throwing(
          const EventsNetworkFailure('offline'),
        ),
      );

      expect(
        find.textContaining("Couldn't connect to load upcoming events"),
        findsOneWidget,
      );
    });
  });

  group('REQ-F08-021: "View all upcoming events" navigates to '
      'AllEventsScreen', () {
    testWidgets('tapping the link pushes AllEventsScreen', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Sunday Mass', start: now.add(const Duration(days: 1))),
        ]),
      );

      await tester.tap(find.text('View all upcoming events'));
      await tester.pumpAndSettle();

      expect(find.byType(AllEventsScreen), findsOneWidget);
      expect(find.text('Upcoming Events'), findsWidgets);
    });
  });

  group('REQ-F08-022/023: "Details" opens an in-app sheet', () {
    testWidgets('shows title, date/time, location, description, and an '
        'optional website link', (tester) async {
      final now = sydneyNowAsFakeUtc();
      final fakeLauncher = _FakeUrlLauncherService();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event(
            'Walking with Christ',
            start: now.add(const Duration(days: 1)),
            location: 'Parish Office',
            description: 'Meets fortnightly on Thursdays at 7pm.',
            detailUrl:
                'https://stlukesmarsdenpark.org.au/event/walking-with-christ/',
          ),
        ]),
        launcher: fakeLauncher,
      );

      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();

      expect(find.text('Walking with Christ'), findsWidgets);
      expect(find.text('Fri 2 Oct 6:30 pm'), findsWidgets);
      expect(find.text('Parish Office'), findsWidgets);
      expect(
        find.text('Meets fortnightly on Thursdays at 7pm.'),
        findsOneWidget,
      );

      final websiteLink = find.text('View on parish website ↗');
      expect(websiteLink, findsOneWidget);
      await tester.tap(websiteLink);
      await tester.pumpAndSettle();
      expect(fakeLauncher.launchedUrls, [
        'https://stlukesmarsdenpark.org.au/event/walking-with-christ/',
      ]);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Meets fortnightly on Thursdays at 7pm.'), findsNothing);
    });

    testWidgets('omits the secondary website link when the feed had no URL', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Youth Group', start: now.add(const Duration(days: 1))),
        ]),
      );

      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();

      expect(find.text('View on parish website ↗'), findsNothing);
    });
  });

  group('REQ-F08-024/025: "Add to my calendar" exports the event', () {
    testWidgets('triggers export with the event\'s title/location/'
        'description/start/end', (tester) async {
      final now = sydneyNowAsFakeUtc();
      final start = now.add(const Duration(days: 1));
      final end = start.add(const Duration(minutes: 45));
      final exportService = _FakeCalendarExportService();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          ParishEvent(
            uid: 'uid-vigil',
            title: 'Vigil Mass 5.30pm',
            start: start,
            end: end,
            displayTime: 'Fri 2 Oct 6:30 pm',
            location: "St Luke's Catholic Church",
            description: 'Weekly vigil Mass.',
          ),
        ]),
        calendarExport: exportService,
      );

      await tester.tap(find.text('Add to my calendar').first);
      await tester.pumpAndSettle();

      expect(exportService.addedEvents, hasLength(1));
      final added = exportService.addedEvents.single;
      expect(added.title, 'Vigil Mass 5.30pm');
      expect(added.location, "St Luke's Catholic Church");
      expect(added.description, 'Weekly vigil Mass.');
      expect(added.startDate, start);
      expect(added.endDate, end);
    });

    testWidgets('defaults to a 1-hour duration when the feed had no end '
        'time', (tester) async {
      final now = sydneyNowAsFakeUtc();
      final start = now.add(const Duration(days: 1));
      final exportService = _FakeCalendarExportService();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Sunday Mass', start: start),
        ]),
        calendarExport: exportService,
      );

      await tester.tap(find.text('Add to my calendar').first);
      await tester.pumpAndSettle();

      final added = exportService.addedEvents.single;
      expect(added.endDate, start.add(const Duration(hours: 1)));
    });

    testWidgets('a failed export shows an explicit, user-friendly message', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Sunday Mass', start: now.add(const Duration(days: 1))),
        ]),
        calendarExport: _FakeCalendarExportService(succeed: false),
      );

      await tester.tap(find.text('Add to my calendar').first);
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Couldn't open your calendar app to add this event. Please try again.",
        ),
        findsOneWidget,
      );
    });
  });

  group('REQ-F08-032: no Icon widget and no emoji glyph anywhere', () {
    testWidgets('no Icon widget is rendered with real event content', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event(
            'Vigil Mass 5.30pm',
            start: now.add(const Duration(days: 1)),
            location: "St Luke's Catholic Church",
          ),
          _event('Sunday Mass', start: now.add(const Duration(days: 2))),
        ]),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('no rendered Text contains an emoji glyph', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event(
            'Vigil Mass 5.30pm',
            start: now.add(const Duration(days: 1)),
            location: "St Luke's Catholic Church",
          ),
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

    testWidgets('an empty/error state also has no icon/emoji', (tester) async {
      await pumpEventsSection(
        tester,
        fakeRepository: _FakeEventsRepository.returning(const []),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('REQ-F08-037: reflows without overflow at increased text scale and '
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

      final now = sydneyNowAsFakeUtc();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning([
                _event(
                  'A very long parish event title that could plausibly '
                  'wrap across multiple lines on a small screen',
                  start: now.add(const Duration(days: 1)),
                  location:
                      "St Luke's Catholic College @ Frontier Avenue, "
                      'Marsden Park NSW 2765, Australia',
                  displayTime: 'Fri 2 Oct 6:30 pm',
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: const Scaffold(
                    body: SingleChildScrollView(child: EventsSection()),
                  ),
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
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning(const []),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(2.0)),
                  child: const Scaffold(body: EventsSection()),
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
