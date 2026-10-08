import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ministries/data/cache/ministries_cache.dart';
import 'package:st_luke_parish_app/features/ministries/data/datasources/bundled_ministries_source.dart';
import 'package:st_luke_parish_app/features/ministries/data/datasources/ministries_remote_datasource.dart';
import 'package:st_luke_parish_app/features/ministries/data/repositories/ministries_repository_impl.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry_category.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';

import '../ministries_json_fixtures.dart';

/// Stale-while-revalidate behaviour: REQ-F08-009..012, plus the detail
/// fetch (REQ-F08-015/016).
class _FakeRemote implements MinistriesRemoteDatasource {
  _FakeRemote({this.body, this.failure});

  final String? body;
  final MinistriesFailure? failure;
  final Map<String, String> byId = {};
  int listCalls = 0;

  @override
  Future<String> fetchMinistriesJson() async {
    listCalls++;
    if (failure != null) throw failure!;
    return body!;
  }

  @override
  Future<String> fetchMinistryJson(String id) async {
    final json = byId[id];
    if (json == null) throw MinistryNotFoundFailure('$id: 404');
    return json;
  }
}

class _MemoryCache implements MinistriesCache {
  _MemoryCache([this.stored]);

  String? stored;
  bool throwOnRead = false;
  bool throwOnWrite = false;
  final List<String> writes = [];

  @override
  Future<String?> read() async {
    if (throwOnRead) throw StateError('prefs unavailable');
    return stored;
  }

  @override
  Future<void> write(String json) async {
    if (throwOnWrite) throw StateError('disk full');
    writes.add(json);
    stored = json;
  }
}

class _FakeBundled implements BundledMinistriesSource {
  _FakeBundled({this.fail = false});

  final bool fail;
  int loads = 0;

  @override
  Future<String> loadJson() async {
    loads++;
    if (fail) throw StateError('asset missing');
    return _singleCategoryBody('Bundled', 'bundled1');
  }
}

String _singleCategoryBody(String category, String id) => jsonEncode({
  'items': [
    {
      'name': category,
      'ministries': [ministryJson(id, category: category)],
    },
  ],
});

List<String> _names(List<MinistryCategory> categories) =>
    categories.map((c) => c.name).toList();

void main() {
  final cachedBody = _singleCategoryBody('Cached', 'cached1');
  const offline = MinistriesNetworkFailure('offline');

  MinistriesRepositoryImpl repository({
    required _FakeRemote remote,
    required _MemoryCache cache,
    _FakeBundled? bundled,
  }) => MinistriesRepositoryImpl(remote, cache, bundled ?? _FakeBundled());

  group('watchMinistries', () {
    test('REQ-F08-009: emits the cache, then the network result, and saves '
        'it', () async {
      final cache = _MemoryCache(cachedBody);
      final bundled = _FakeBundled();
      final emitted = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
        bundled: bundled,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cached'],
        ['Cat A', 'Cat B'],
      ]);
      expect(cache.stored, ministriesBody());
      expect(bundled.loads, 0);
    });

    test('REQ-F08-010: when the network fails, the cache stays on screen and '
        'in storage', () async {
      final cache = _MemoryCache(cachedBody);
      final bundled = _FakeBundled();
      final emitted = await repository(
        remote: _FakeRemote(failure: offline),
        cache: cache,
        bundled: bundled,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cached'],
      ]);
      expect(cache.writes, isEmpty);
      expect(cache.stored, cachedBody);
      expect(bundled.loads, 0);
    });

    test('REQ-F08-011: with no cache and no network, emits the bundled copy '
        'and does not save it', () async {
      final cache = _MemoryCache();
      final bundled = _FakeBundled();
      final emitted = await repository(
        remote: _FakeRemote(failure: offline),
        cache: cache,
        bundled: bundled,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Bundled'],
      ]);
      expect(bundled.loads, 1);
      expect(cache.writes, isEmpty);
    });

    test('with no cache and a network, emits only the fresh list', () async {
      final cache = _MemoryCache();
      final bundled = _FakeBundled();
      final emitted = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
        bundled: bundled,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cat A', 'Cat B'],
      ]);
      expect(bundled.loads, 0);
      expect(cache.writes, [ministriesBody()]);
    });

    test('REQ-F08-008: an unconfigured API base falls back like a network '
        'failure', () async {
      final emitted = await repository(
        remote: _FakeRemote(
          failure: const MinistriesNotConfiguredFailure('no API_BASE_URL'),
        ),
        cache: _MemoryCache(),
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Bundled'],
      ]);
    });

    test('a malformed network response keeps the cache and is not '
        'saved', () async {
      final cache = _MemoryCache(cachedBody);
      final emitted = await repository(
        remote: _FakeRemote(body: '{"items": [{"name": 1}]}'),
        cache: cache,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cached'],
      ]);
      expect(cache.stored, cachedBody);
    });

    test('REQ-F08-012: a corrupt cache entry is a miss and gets '
        'replaced', () async {
      final cache = _MemoryCache('{not json');
      final emitted = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cat A', 'Cat B'],
      ]);
      expect(cache.stored, ministriesBody());
    });

    test('a corrupt cache entry while offline falls back to the bundled '
        'copy', () async {
      final emitted = await repository(
        remote: _FakeRemote(failure: offline),
        cache: _MemoryCache('{"items": "nope"}'),
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Bundled'],
      ]);
    });

    test('an unreadable cache is a miss', () async {
      final cache = _MemoryCache(cachedBody)..throwOnRead = true;
      final emitted = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cat A', 'Cat B'],
      ]);
    });

    test('a failed cache write still emits the fresh list', () async {
      final cache = _MemoryCache()..throwOnWrite = true;
      final emitted = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
      ).watchMinistries().toList();

      expect(emitted.map(_names), [
        ['Cat A', 'Cat B'],
      ]);
    });

    test('a bundled copy that fails to load is a parsing failure', () async {
      await expectLater(
        repository(
          remote: _FakeRemote(failure: offline),
          cache: _MemoryCache(),
          bundled: _FakeBundled(fail: true),
        ).watchMinistries().toList(),
        throwsA(isA<MinistriesParsingFailure>()),
      );
    });
  });

  group('refreshMinistries', () {
    test('returns and saves the network result', () async {
      final cache = _MemoryCache(cachedBody);
      final categories = await repository(
        remote: _FakeRemote(body: ministriesBody()),
        cache: cache,
      ).refreshMinistries();

      expect(_names(categories), ['Cat A', 'Cat B']);
      expect(cache.stored, ministriesBody());
    });

    test('rethrows a failure and leaves the cache untouched', () async {
      final cache = _MemoryCache(cachedBody);
      await expectLater(
        repository(
          remote: _FakeRemote(failure: offline),
          cache: cache,
        ).refreshMinistries(),
        throwsA(isA<MinistriesNetworkFailure>()),
      );
      expect(cache.stored, cachedBody);
    });
  });

  group('getMinistryById', () {
    test('REQ-F08-015: parses the fetched ministry', () async {
      final remote = _FakeRemote(body: ministriesBody());
      remote.byId['solo'] = jsonEncode(ministryJson('solo'));

      final ministry = await repository(
        remote: remote,
        cache: _MemoryCache(),
      ).getMinistryById('solo');

      expect(ministry.id, 'solo');
    });

    test('REQ-F08-016: a 404 propagates as MinistryNotFoundFailure', () async {
      await expectLater(
        repository(
          remote: _FakeRemote(body: ministriesBody()),
          cache: _MemoryCache(),
        ).getMinistryById('gone'),
        throwsA(isA<MinistryNotFoundFailure>()),
      );
    });
  });
}
