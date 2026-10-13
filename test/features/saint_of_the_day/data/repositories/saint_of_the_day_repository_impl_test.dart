import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/saint_of_the_day/data/cache/saint_of_the_day_cache.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/repositories/saint_of_the_day_repository_impl.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

import '../saint_json_fixtures.dart';

/// Fake [SaintOfTheDayRemoteDatasource] that records the requested keys and
/// answers with [respond]. The real datasource's HTTP mapping has its own
/// tests.
class _FakeDatasource implements SaintOfTheDayRemoteDatasource {
  _FakeDatasource(this.respond);

  final Future<String> Function(String dateKey) respond;
  final List<String> requested = [];

  @override
  Future<String> fetchSaintJson(String dateKey) {
    requested.add(dateKey);
    return respond(dateKey);
  }
}

/// In-memory [SaintOfTheDayCache] recording reads and writes.
class _FakeCache implements SaintOfTheDayCache {
  final Map<String, SaintOfTheDay> store = {};
  final List<String> reads = [];
  final List<String> writes = [];

  @override
  Future<SaintOfTheDay?> read(String dateKey) async {
    reads.add(dateKey);
    return store[dateKey];
  }

  @override
  Future<void> write(String dateKey, SaintOfTheDay value) async {
    writes.add(dateKey);
    store[dateKey] = value;
  }
}

/// A cache whose `write` always fails, for asserting caching is
/// best-effort.
class _FailingWriteCache extends _FakeCache {
  @override
  Future<void> write(String dateKey, SaintOfTheDay value) async {
    throw Exception('shared_preferences write failed');
  }
}

const _cachedSaint = SaintOfTheDay(
  name: 'Cached Saint',
  feast: '',
  bornDied: '',
  about: 'From the cache.',
  saying: '',
  didYouKnow: '',
  patronOf: '',
  prayer: '',
  dateKey: '2026-10-12',
  displayDate: 'October 12',
);

/// 09:00 Sydney on 12 October 2026 (the clock returns Sydney wall time).
DateTime _oct12() => DateTime.utc(2026, 10, 12, 9);

void main() {
  SaintOfTheDayRepositoryImpl repo(
    _FakeDatasource datasource,
    _FakeCache cache, {
    DateTime Function() clock = _oct12,
  }) => SaintOfTheDayRepositoryImpl(datasource, cache, clock: clock);

  group('cache (REQ-F09-011/012)', () {
    test('reads the cache and requests with the same Sydney key', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource((key) async => saintJson());

      await repo(datasource, cache).getTodaysSaint();

      expect(cache.reads, ['2026-10-12']);
      expect(datasource.requested, ['2026-10-12']);
    });

    test('a cache hit returns it without a request', () async {
      final cache = _FakeCache()..store['2026-10-12'] = _cachedSaint;
      final datasource = _FakeDatasource(
        (key) async => throw StateError('should not be reached'),
      );

      final result = await repo(datasource, cache).getTodaysSaint();

      expect(result.name, 'Cached Saint');
      expect(datasource.requested, isEmpty);
    });

    test('a miss fetches, caches and returns; the next call hits', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource((key) async => saintJson());
      final repository = repo(datasource, cache);

      final result = await repository.getTodaysSaint();
      expect(result.name, 'Saint Wilfrid, Bishop');
      expect(cache.writes, ['2026-10-12']);

      await repository.getTodaysSaint();
      expect(datasource.requested, hasLength(1));
    });

    test('writes and displays the server dateKey and displayDate, even '
        'when it differs from the requested key (D-7, REQ-F09-013)', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource(
        (key) async => saintJson(
          dateKey: '2026-10-13',
          overrides: {'displayDate': 'October 13'},
        ),
      );

      final result = await repo(datasource, cache).getTodaysSaint();

      expect(datasource.requested, ['2026-10-12']);
      expect(result.dateKey, '2026-10-13');
      expect(result.displayDate, 'October 13');
      expect(cache.writes, ['2026-10-13']);
    });

    test('a failed cache write still returns the saint', () async {
      final datasource = _FakeDatasource((key) async => saintJson());

      final result = await repo(
        datasource,
        _FailingWriteCache(),
      ).getTodaysSaint();

      expect(result.name, 'Saint Wilfrid, Bishop');
    });
  });

  group('content guards (D-6, REQ-F09-009)', () {
    for (final name in ['', '   ']) {
      test('name "$name" is a parsing failure and is not cached', () async {
        final cache = _FakeCache();
        final datasource = _FakeDatasource(
          (key) async => saintJson(overrides: {'name': name}),
        );

        await expectLater(
          repo(datasource, cache).getTodaysSaint(),
          throwsA(isA<SaintOfTheDayParsingFailure>()),
        );
        expect(cache.writes, isEmpty);
      });
    }

    test('all six content sections empty is a parsing failure and is not '
        'cached', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource(
        (key) async => saintJson(
          overrides: {
            'about': '',
            'bornDied': '',
            'saying': '',
            'didYouKnow': '',
            'patronOf': ' ',
            'prayer': '',
          },
        ),
      );

      await expectLater(
        repo(datasource, cache).getTodaysSaint(),
        throwsA(isA<SaintOfTheDayParsingFailure>()),
      );
      expect(cache.writes, isEmpty);
    });

    test('a single populated section is enough', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource(
        (key) async => saintJson(
          overrides: {
            'about': '',
            'bornDied': '',
            'saying': '',
            'didYouKnow': '',
            'patronOf': '',
          },
        ),
      );

      final result = await repo(datasource, cache).getTodaysSaint();

      expect(result.prayer, 'Saint Wilfrid, pray for us.');
      expect(cache.writes, hasLength(1));
    });

    test('a malformed body is a parsing failure naming the dateKey', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource((key) async => 'not json');

      await expectLater(
        repo(datasource, cache).getTodaysSaint(),
        throwsA(
          isA<SaintOfTheDayParsingFailure>().having(
            (f) => f.message,
            'message',
            contains('2026-10-12'),
          ),
        ),
      );
      expect(cache.writes, isEmpty);
    });
  });

  group('failures leave the cache untouched (REQ-F09-014)', () {
    for (final failure in <SaintOfTheDayFailure>[
      const SaintOfTheDayNotConfiguredFailure('no base'),
      const SaintOfTheDayNetworkFailure('offline'),
      const SaintOfTheDayNotReadyFailure('503'),
      const SaintOfTheDayDateUnavailableFailure('404'),
      const SaintOfTheDayUnavailableFailure('401'),
    ]) {
      test('${failure.runtimeType} propagates unchanged', () async {
        final cache = _FakeCache()..store['2026-10-11'] = _cachedSaint;
        final datasource = _FakeDatasource((key) async => throw failure);

        await expectLater(
          repo(datasource, cache).getTodaysSaint(),
          throwsA(same(failure)),
        );
        expect(cache.writes, isEmpty);
        expect(cache.store.keys, ['2026-10-11']);
      });
    }

    test('an unexpected exception becomes a network failure', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource(
        (key) async => throw http.ClientException('boom'),
      );

      await expectLater(
        repo(datasource, cache).getTodaysSaint(),
        throwsA(isA<SaintOfTheDayNetworkFailure>()),
      );
      expect(cache.writes, isEmpty);
    });
  });

  group('injectable clock', () {
    test('rollover past Sydney midnight requests the new date', () async {
      final cache = _FakeCache();
      final datasource = _FakeDatasource(
        (key) async => saintJson(dateKey: key),
      );
      var now = DateTime.utc(2026, 10, 12, 23, 59);
      final repository = repo(datasource, cache, clock: () => now);

      await repository.getTodaysSaint();
      await repository.getTodaysSaint();
      expect(datasource.requested, ['2026-10-12']);

      now = DateTime.utc(2026, 10, 13, 0, 1);
      final next = await repository.getTodaysSaint();

      expect(datasource.requested, ['2026-10-12', '2026-10-13']);
      expect(next.dateKey, '2026-10-13');
    });
  });
}
