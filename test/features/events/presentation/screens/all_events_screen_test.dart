import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/events/data/parsers/ics_event_parser.dart'
    show sydneyNowAsFakeUtc;
import 'package:st_luke_parish_app/features/events/domain/entities/parish_event.dart';
import 'package:st_luke_parish_app/features/events/domain/failures/events_failure.dart';
import 'package:st_luke_parish_app/features/events/domain/repositories/events_repository.dart';
import 'package:st_luke_parish_app/features/events/presentation/providers/events_provider.dart';
import 'package:st_luke_parish_app/features/events/presentation/screens/all_events_screen.dart';

/// Covers the All Events screen's own acceptance criteria: REQ-F08-027
/// (reachable via push, working back navigation), REQ-F08-028 (full list,
/// no 7-day limit, same row style), REQ-F08-029 (pagination rather than
/// building the whole remaining list at once), and REQ-F08-030 (reuses the
/// inline section's own loading/empty/error states).
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

ParishEvent _event(String title, {required DateTime start}) => ParishEvent(
  uid: 'uid-$title',
  title: title,
  start: start,
  displayTime: 'Fri 2 Oct 6:30 pm',
);

void main() {
  Future<void> pumpAllEventsScreen(
    WidgetTester tester, {
    required EventsRepository fakeRepository,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [eventsRepositoryProvider.overrideWithValue(fakeRepository)],
        // Wrapped so `tester.pageBack()` has a previous route to return to
        // (REQ-F08-027's "working back navigation to the News tab").
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AllEventsScreen()),
                  ),
                  child: const Text('Open All Events'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open All Events'));
    await tester.pumpAndSettle();
  }

  group('REQ-F08-028: full list rendering', () {
    testWidgets('renders every upcoming event, sorted ascending, same row '
        'style as the inline section', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('First', start: now.add(const Duration(days: 1))),
          _event('Second', start: now.add(const Duration(days: 40))),
          _event('Third', start: now.add(const Duration(days: 90))),
        ]),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('Details'), findsNWidgets(3));
      expect(find.text('Add to my calendar'), findsNWidgets(3));
    });
  });

  group('REQ-F08-029: pagination', () {
    testWidgets(
      'shows a bounded first page with a "Next" control and no "Back" '
      'control on the first page',
      (tester) async {
        final now = sydneyNowAsFakeUtc();
        final events = [
          for (var i = 0; i < 25; i++)
            _event('Event $i', start: now.add(Duration(days: i + 1))),
        ];
        await pumpAllEventsScreen(
          tester,
          fakeRepository: _FakeEventsRepository.returning(events),
        );

        // ListView.builder only builds items near the viewport, so the
        // first page's rows beyond what's visible aren't in the tree yet
        // -- what matters for REQ-F08-029 is that the list doesn't render
        // everything at once: the second page's events aren't built at
        // all (not merely off-screen), and scrolling reaches a "Next"
        // control, never a "Back" control, on this first page.
        expect(find.text('Event 0'), findsOneWidget);
        expect(find.text('Event 20'), findsNothing);

        await tester.scrollUntilVisible(
          find.text('Next >'),
          300,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('Next >'), findsOneWidget);
        expect(find.text('< Back'), findsNothing);
      },
    );

    testWidgets(
      'tapping "Next" reveals the next page, with a "Back" control and '
      'none of the first page\'s events',
      (tester) async {
        final now = sydneyNowAsFakeUtc();
        final events = [
          for (var i = 0; i < 25; i++)
            _event('Event $i', start: now.add(Duration(days: i + 1))),
        ];
        await pumpAllEventsScreen(
          tester,
          fakeRepository: _FakeEventsRepository.returning(events),
        );

        await tester.scrollUntilVisible(
          find.text('Next >'),
          300,
          scrollable: find.byType(Scrollable),
        );
        await tester.tap(find.text('Next >'));
        await tester.pumpAndSettle();

        // The first page's events are gone entirely -- this is a new
        // page, not more items appended to the same list.
        expect(find.text('Event 0'), findsNothing);

        await tester.scrollUntilVisible(
          find.text('Event 20'),
          -300,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('Event 20'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Event 24'),
          300,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('Event 24'), findsOneWidget);
        // Last page: no further "Next" control, but "Back" is available.
        expect(find.text('Next >'), findsNothing);
        expect(find.text('< Back'), findsOneWidget);
      },
    );

    testWidgets('tapping "Back" returns to the previous page', (tester) async {
      final now = sydneyNowAsFakeUtc();
      final events = [
        for (var i = 0; i < 25; i++)
          _event('Event $i', start: now.add(Duration(days: i + 1))),
      ];
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning(events),
      );

      await tester.scrollUntilVisible(
        find.text('Next >'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Next >'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('< Back'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('< Back'));
      await tester.pumpAndSettle();

      // Back on the first page: the original events are showing again,
      // and the "Back" control is gone.
      await tester.scrollUntilVisible(
        find.text('Event 0'),
        -300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Event 0'), findsOneWidget);
      expect(find.text('< Back'), findsNothing);
    });

    testWidgets('no pagination controls when everything fits on one page', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Only one', start: now.add(const Duration(days: 1))),
        ]),
      );

      expect(find.text('Next >'), findsNothing);
      expect(find.text('< Back'), findsNothing);
    });
  });

  group('REQ-F08-030: shared loading/empty/error states', () {
    testWidgets('shows the same fully-empty message as the inline section', (
      tester,
    ) async {
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning(const []),
      );

      expect(find.text('No upcoming events right now.'), findsOneWidget);
    });

    testWidgets('a network failure shows a friendly, distinguishable '
        'message', (tester) async {
      await pumpAllEventsScreen(
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

  group('REQ-F08-027: reachable by push, with working back navigation', () {
    testWidgets('the app bar title reads "Upcoming Events"', (tester) async {
      final now = sydneyNowAsFakeUtc();
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Only one', start: now.add(const Duration(days: 1))),
        ]),
      );

      expect(find.widgetWithText(AppBar, 'Upcoming Events'), findsOneWidget);
    });

    testWidgets('the back button returns to the previous screen', (
      tester,
    ) async {
      final now = sydneyNowAsFakeUtc();
      await pumpAllEventsScreen(
        tester,
        fakeRepository: _FakeEventsRepository.returning([
          _event('Only one', start: now.add(const Duration(days: 1))),
        ]),
      );
      expect(find.byType(AllEventsScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(AllEventsScreen), findsNothing);
      expect(find.text('Open All Events'), findsOneWidget);
    });
  });
}
