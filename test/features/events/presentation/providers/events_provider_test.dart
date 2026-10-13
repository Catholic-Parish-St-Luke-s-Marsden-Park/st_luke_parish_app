import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/events/domain/entities/parish_event.dart';
import 'package:st_luke_parish_app/features/events/domain/failures/events_failure.dart';
import 'package:st_luke_parish_app/features/events/domain/repositories/events_repository.dart';
import 'package:st_luke_parish_app/features/events/presentation/providers/events_provider.dart';

/// Covers REQ-F08-012 (events exposed as `AsyncValue<List<ParishEvent>>` via
/// a Riverpod provider) and the loading/success/empty/network-failure/
/// parsing-failure `AsyncValue` states per REQ-F08-039(b), independent of
/// any widget tree. Mirrors `bulletins_provider_test.dart`'s structure
/// exactly.
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

ParishEvent _event(String title, {DateTime? start}) => ParishEvent(
  uid: 'uid-$title',
  title: title,
  start: start ?? DateTime.utc(2026, 10, 2, 18, 30),
  displayTime: 'Fri 2 Oct 6:30 pm',
  location: 'St Luke\'s Catholic Parish',
);

void main() {
  group('success states', () {
    test('single-item result is exposed via AsyncData', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository.returning([_event('Only one')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(upcomingEventsProvider.future);

      expect(result, hasLength(1));
      expect(result.single.title, 'Only one');
    });

    test(
      'multi-item result is exposed via AsyncData in the given order',
      () async {
        final container = ProviderContainer(
          overrides: [
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning([
                _event('First'),
                _event('Second'),
                _event('Third'),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(upcomingEventsProvider.future);

        expect(result.map((e) => e.title), ['First', 'Second', 'Third']);
      },
    );
  });

  group('empty result', () {
    test(
      'an empty repository result is exposed as an empty AsyncData list',
      () async {
        final container = ProviderContainer(
          overrides: [
            eventsRepositoryProvider.overrideWithValue(
              _FakeEventsRepository.returning([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(upcomingEventsProvider.future);

        expect(result, isEmpty);
      },
    );
  });

  group('loading state', () {
    test('the provider starts in a loading state before resolution', () {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository.returning([_event('Loading test')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(upcomingEventsProvider);

      expect(initial, isA<AsyncLoading<List<ParishEvent>>>());
    });
  });

  group('network failure', () {
    test('an EventsNetworkFailure surfaces as AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository.throwing(
              const EventsNetworkFailure('offline'),
            ),
          ),
        ],
        // The app's own retry policy (`main.dart` passes the same symbol to
        // its ProviderScope): no automatic retry, so a failure settles into
        // AsyncError immediately.
        retry: noAutomaticRetry,
      );
      addTearDown(container.dispose);

      // Autodispose providers can otherwise be torn down while still
      // loading; an active listener keeps this one alive until it settles.
      container.listen(upcomingEventsProvider, (_, _) {});

      await expectLater(
        container.read(upcomingEventsProvider.future),
        throwsA(isA<EventsNetworkFailure>()),
      );
    });
  });

  group('parsing failure', () {
    test('an EventsParsingFailure surfaces as AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(
            _FakeEventsRepository.throwing(
              const EventsParsingFailure('malformed'),
            ),
          ),
        ],
        // See the network-failure test above for why retry is disabled.
        retry: noAutomaticRetry,
      );
      addTearDown(container.dispose);

      // See the network-failure test above for why this listener is needed.
      container.listen(upcomingEventsProvider, (_, _) {});

      await expectLater(
        container.read(upcomingEventsProvider.future),
        throwsA(isA<EventsParsingFailure>()),
      );
    });
  });
}
