import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/cache/saint_of_the_day_cache.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/openrouter_saint_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/repositories/saint_of_the_day_repository_impl.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/sydney_date.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

/// [SaintOfTheDayRepositoryImpl] takes a concrete [OpenRouterSaintDatasource]
/// (same pattern as `FeedBulletinsRepository`/`BulletinsFeedDatasource`), so
/// these tests exercise it via a fake implementing that class directly,
/// rather than mocking the parser/HTTP layer.
class _FakeDatasource implements OpenRouterSaintDatasource {
  _FakeDatasource.returningText(this._text)
    : _error = null,
      isConfigured = true;
  _FakeDatasource.throwing(Object error)
    : _text = null,
      _error = error,
      isConfigured = true;
  _FakeDatasource.notConfigured()
    : _text = null,
      _error = null,
      isConfigured = false;

  final String? _text;
  final Object? _error;

  @override
  final bool isConfigured;

  @override
  Future<String> fetchSaintText(String fullDate) async {
    if (_error != null) throw _error;
    return _text!;
  }
}

/// Fake in-memory [SaintOfTheDayCache] — the repository's own contract,
/// not the `shared_preferences` implementation (that has its own direct
/// test).
class _FakeCache implements SaintOfTheDayCache {
  final Map<String, SaintOfTheDay> _store = {};
  int readCount = 0;
  int writeCount = 0;

  @override
  Future<SaintOfTheDay?> read(String dateKey) async {
    readCount++;
    return _store[dateKey];
  }

  @override
  Future<void> write(String dateKey, SaintOfTheDay value) async {
    writeCount++;
    _store[dateKey] = value;
  }
}

void main() {
  group('getTodaysSaint — cache hit (REQ-F06-008)', () {
    test('returns the cached value without calling the datasource', () async {
      final cache = _FakeCache();
      const cachedSaint = SaintOfTheDay(
        name: 'Cached Saint',
        feast: '',
        bornDied: '',
        about: '',
        saying: '',
        didYouKnow: '',
        patronOf: '',
        prayer: '',
        dateKey: 'irrelevant',
        displayDate: 'irrelevant',
      );
      final todayKey = sydneyDateKey(sydneyNow());
      await cache.write(todayKey, cachedSaint);

      // Would throw if ever reached — proves the cache-hit path never
      // calls the datasource.
      final datasource = _FakeDatasource.throwing(
        StateError('datasource should not be reached on a cache hit'),
      );
      final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

      final result = await repository.getTodaysSaint();

      expect(result.name, 'Cached Saint');
      expect(cache.readCount, 1);
      expect(cache.writeCount, 1); // only the setup write above
    });
  });

  group('getTodaysSaint — cache miss, successful fetch (REQ-F06-009)', () {
    test('fetches, parses, caches, and returns the result', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource.returningText(
        '**SAINT NAME:**\nSaint Fresh\n**ABOUT:**\nA fresh fetch.\n',
      );
      final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

      final result = await repository.getTodaysSaint();

      expect(result.name, 'Saint Fresh');
      expect(result.about, 'A fresh fetch.');
      expect(cache.writeCount, 1);

      // A second call within the same day now hits the cache, not the
      // (would-throw) datasource again.
      final again = await repository.getTodaysSaint();
      expect(again.name, 'Saint Fresh');
      expect(cache.writeCount, 1); // unchanged — no second fetch
    });
  });

  group('getTodaysSaint — not configured (REQ-F06-003)', () {
    test(
      'throws SaintOfTheDayNotConfiguredFailure without writing to cache',
      () async {
        final cache = _FakeCache();
        final datasource = _FakeDatasource.notConfigured();
        final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

        await expectLater(
          repository.getTodaysSaint(),
          throwsA(isA<SaintOfTheDayNotConfiguredFailure>()),
        );
        expect(cache.writeCount, 0);
      },
    );
  });

  group('getTodaysSaint — datasource failure propagation', () {
    test(
      'a SaintOfTheDayNetworkFailure from the datasource propagates',
      () async {
        final cache = _FakeCache();
        final datasource = _FakeDatasource.throwing(
          const SaintOfTheDayNetworkFailure('network down'),
        );
        final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

        await expectLater(
          repository.getTodaysSaint(),
          throwsA(isA<SaintOfTheDayNetworkFailure>()),
        );
        expect(cache.writeCount, 0);
      },
    );

    test(
      'an unexpected exception is converted to SaintOfTheDayNetworkFailure',
      () async {
        final cache = _FakeCache();
        final datasource = _FakeDatasource.throwing(Exception('boom'));
        final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

        await expectLater(
          repository.getTodaysSaint(),
          throwsA(isA<SaintOfTheDayNetworkFailure>()),
        );
      },
    );
  });
}
