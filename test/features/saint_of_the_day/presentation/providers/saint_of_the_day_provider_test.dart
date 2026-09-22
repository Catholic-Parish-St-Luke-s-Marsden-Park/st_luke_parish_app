import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/repositories/saint_of_the_day_repository.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/providers/saint_of_the_day_provider.dart';

/// Covers REQ-F06-011's `AsyncValue` loading/success/failure states at the
/// provider level, independent of any widget tree — mirrors
/// `bulletins_provider_test.dart`'s approach.
class _FakeRepository implements SaintOfTheDayRepository {
  _FakeRepository.returning(this._result) : _error = null;
  _FakeRepository.throwing(Object error) : _result = null, _error = error;

  final SaintOfTheDay? _result;
  final Object? _error;

  @override
  Future<SaintOfTheDay> getTodaysSaint() async {
    if (_error != null) throw _error;
    return _result!;
  }
}

const _saint = SaintOfTheDay(
  name: 'Saint Example',
  feast: 'A feast',
  bornDied: '',
  about: 'About text',
  saying: '',
  didYouKnow: '',
  patronOf: '',
  prayer: '',
  dateKey: '2026-09-01',
  displayDate: 'September 1',
);

void main() {
  test('a successful repository result is exposed via AsyncData', () async {
    final container = ProviderContainer(
      overrides: [
        saintOfTheDayRepositoryProvider.overrideWith(
          (ref) async => _FakeRepository.returning(_saint),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(saintOfTheDayProvider.future);

    expect(result.name, 'Saint Example');
    expect(result.about, 'About text');
  });

  test('a network failure surfaces as an AsyncError', () async {
    final container = ProviderContainer(
      overrides: [
        saintOfTheDayRepositoryProvider.overrideWith(
          (ref) async => _FakeRepository.throwing(
            const SaintOfTheDayNetworkFailure('down'),
          ),
        ),
      ],
      // The app's own retry policy (`main.dart` passes the same symbol
      // to its ProviderScope): no automatic retry, so a failure settles
      // into AsyncError immediately. Using it here rather than a
      // test-local literal keeps test and production behaviour in step.
      retry: noAutomaticRetry,
    );
    addTearDown(container.dispose);

    // Autodispose providers can otherwise be torn down while still
    // loading; an active listener keeps this one alive until it settles.
    container.listen(saintOfTheDayProvider, (_, _) {});

    await expectLater(
      container.read(saintOfTheDayProvider.future),
      throwsA(isA<SaintOfTheDayNetworkFailure>()),
    );
  });

  test('a not-configured failure surfaces as an AsyncError', () async {
    final container = ProviderContainer(
      overrides: [
        saintOfTheDayRepositoryProvider.overrideWith(
          (ref) async => _FakeRepository.throwing(
            const SaintOfTheDayNotConfiguredFailure('no key'),
          ),
        ),
      ],
      // See the network-failure test above for why retry is disabled.
      retry: noAutomaticRetry,
    );
    addTearDown(container.dispose);

    // See the network-failure test above for why this listener is needed.
    container.listen(saintOfTheDayProvider, (_, _) {});

    await expectLater(
      container.read(saintOfTheDayProvider.future),
      throwsA(isA<SaintOfTheDayNotConfiguredFailure>()),
    );
  });
}
