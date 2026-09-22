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

  /// Mirrors the real datasource: the not-configured check lives here,
  /// where the API key lives, and throws before any request is made. The
  /// repository no longer duplicates it.
  @override
  Future<String> fetchSaintText(String fullDate) async {
    if (!isConfigured) {
      throw const SaintOfTheDayNotConfiguredFailure(
        'OPENROUTER_API_KEY was not supplied at build/run time.',
      );
    }
    if (_error != null) throw _error;
    return _text!;
  }
}

/// A cache whose `write` always fails, for asserting that caching is
/// best-effort and cannot fail a read that already succeeded.
class _FailingWriteCache implements SaintOfTheDayCache {
  @override
  Future<SaintOfTheDay?> read(String dateKey) async => null;

  @override
  Future<void> write(String dateKey, SaintOfTheDay value) async {
    throw Exception('shared_preferences write failed');
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

  group('getTodaysSaint — degenerate parse (REQ-F06-007)', () {
    // The parser is deliberately tolerant: a response with no
    // recognisable `**LABEL:**` sections yields the default name and
    // eight empty strings rather than throwing. Left unchecked that
    // reaches the screen as an AsyncData success with a header and no
    // section cards — a blank page with no error view and no retry — and
    // gets cached, pinning the user to it for the rest of the day.
    const refusal = "I'm sorry, I can't help with that request.";

    test(
      'a section-less response throws SaintOfTheDayParsingFailure',
      () async {
        final cache = _FakeCache();
        final datasource = _FakeDatasource.returningText(refusal);
        final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

        await expectLater(
          repository.getTodaysSaint(),
          throwsA(isA<SaintOfTheDayParsingFailure>()),
        );
      },
    );

    test('a section-less response is not cached', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource.returningText(refusal);
      final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

      await expectLater(
        repository.getTodaysSaint(),
        throwsA(isA<SaintOfTheDayParsingFailure>()),
      );

      expect(cache.writeCount, 0);
    });

    test('a name-only response is rejected too', () async {
      // A name alone renders as a header and nothing else — still blank.
      final cache = _FakeCache();
      final datasource = _FakeDatasource.returningText(
        '**SAINT NAME:**\nSaint Nobody\n',
      );
      final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

      await expectLater(
        repository.getTodaysSaint(),
        throwsA(isA<SaintOfTheDayParsingFailure>()),
      );
      expect(cache.writeCount, 0);
    });

    test('a single populated section is enough to succeed', () async {
      // The guard must reject only genuinely empty parses — a partial
      // response the screen can still render is a success, matching
      // REQ-F06-006's tolerant "missing section -> empty string".
      final cache = _FakeCache();
      final datasource = _FakeDatasource.returningText(
        '**SAINT NAME:**\nSaint Partial\n**PRAYER:**\nA short prayer.\n',
      );
      final repository = SaintOfTheDayRepositoryImpl(datasource, cache);

      final result = await repository.getTodaysSaint();

      expect(result.name, 'Saint Partial');
      expect(result.prayer, 'A short prayer.');
      expect(result.about, isEmpty);
      expect(cache.writeCount, 1);
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

  group('getTodaysSaint — caching is best-effort', () {
    test(
      'a cache write failure does not fail an otherwise good read',
      () async {
        // The content has already been fetched and paid for; a
        // shared_preferences failure must not turn it into an error state.
        final datasource = _FakeDatasource.returningText(
          '**SAINT NAME:**\nSaint Resilient\n**ABOUT:**\nStill returned.\n',
        );
        final repository = SaintOfTheDayRepositoryImpl(
          datasource,
          _FailingWriteCache(),
        );

        final result = await repository.getTodaysSaint();

        expect(result.name, 'Saint Resilient');
        expect(result.about, 'Still returned.');
      },
    );
  });

  group('getTodaysSaint — injectable clock (REQ-F06-009)', () {
    // The repository takes a clock so day rollover can be driven
    // directly, rather than the test depending on the real wall clock
    // (which cannot cover rollover and is flaky across Sydney midnight).
    const sourceText = '**SAINT NAME:**\nSaint Monday\n**ABOUT:**\nA saint.\n';

    test('derives the cache key from the injected clock', () async {
      final cache = _FakeCache();
      final repository = SaintOfTheDayRepositoryImpl(
        _FakeDatasource.returningText(sourceText),
        cache,
        clock: () => DateTime(2026, 9, 1, 9),
      );

      final result = await repository.getTodaysSaint();

      expect(result.dateKey, '2026-09-01');
      expect(result.displayDate, 'September 1');
    });

    test('a new day misses the previous day\'s entry and re-fetches', () async {
      final cache = _FakeCache();
      var now = DateTime(2026, 9, 1, 23);

      final repository = SaintOfTheDayRepositoryImpl(
        _FakeDatasource.returningText(sourceText),
        cache,
        clock: () => now,
      );

      final day1 = await repository.getTodaysSaint();
      expect(day1.dateKey, '2026-09-01');
      expect(cache.writeCount, 1);

      // Same day again -> cache hit, no additional write.
      await repository.getTodaysSaint();
      expect(cache.writeCount, 1);

      // Roll over past Sydney midnight.
      now = DateTime(2026, 9, 2, 1);
      final day2 = await repository.getTodaysSaint();

      expect(day2.dateKey, '2026-09-02');
      expect(day2.displayDate, 'September 2');
      expect(cache.writeCount, 2);
    });
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
