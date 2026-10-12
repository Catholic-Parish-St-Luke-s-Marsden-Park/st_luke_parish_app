import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/cache/saint_of_the_day_cache.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/repositories/saint_of_the_day_repository_impl.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/sydney_date.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

import '../saint_json_fixtures.dart';

/// Tester phase: the repository wired to the *real* datasource (on a
/// `MockClient`) and the *real* shared_preferences cache, with the clock
/// composed from `sydneyNow(fixedUtc)` exactly as production composes it.
/// `saint_of_the_day_repository_impl_test.dart` covers the same rules with
/// fakes; this file checks they still hold end to end through the real
/// storage format and HTTP mapping (REQ-F09-011..014, REQ-F09-001).
const _dateKeyPref = 'saint_of_the_day_cache_date_key';
const _valuePref = 'saint_of_the_day_cache_value';

/// A shared_preferences store whose writes always throw, simulating a
/// platform-channel failure rather than a `false` return.
class _ThrowingWriteStore extends SharedPreferencesStorePlatform {
  final Map<String, Object> _store = {};

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      throw Exception('platform write failed');

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_store);

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async => Map.of(_store);

  @override
  Future<bool> remove(String key) async => _store.remove(key) != null;

  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    _store.clear();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ensures no test here leaks a custom store into the next.
  tearDown(SharedPreferences.resetStatic);

  /// 09:00 Sydney (AEDT) on 12 October 2026, expressed in UTC.
  final oct12MorningUtc = DateTime.utc(2026, 10, 11, 22);

  late List<Uri> requested;

  Future<SaintOfTheDayRepositoryImpl> repoWith({
    required Future<http.Response> Function(http.Request request) respond,
    Map<String, Object> initialPrefs = const {},
    DateTime Function()? utcClock,
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    requested = [];
    final clock = utcClock ?? () => oct12MorningUtc;
    return SaintOfTheDayRepositoryImpl(
      SaintOfTheDayRemoteDatasource(
        MockClient((request) {
          requested.add(request.url);
          return respond(request);
        }),
        baseUri: Uri.parse('https://api.example.org'),
      ),
      SharedPreferencesSaintOfTheDayCache(prefs),
      clock: () => sydneyNow(clock()),
    );
  }

  Future<Map<String, Object?>> prefsSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return {for (final k in prefs.getKeys()) k: prefs.get(k)};
  }

  String storedEntry(String dateKey, {String name = 'Stored Saint'}) =>
      jsonEncode(saintPayload(dateKey: dateKey, overrides: {'name': name}));

  test('a cold start requests today\'s Sydney key and stores the entry '
      'under the server dateKey', () async {
    final repo = await repoWith(
      respond: (request) async => http.Response(saintJson(), 200),
    );

    final saint = await repo.getTodaysSaint();

    expect(saint.name, 'Saint Wilfrid, Bishop');
    expect(requested.map((u) => u.path), ['/v1/saints/2026-10-12']);
    final prefs = await prefsSnapshot();
    expect(prefs[_dateKeyPref], '2026-10-12');
    expect(
      (jsonDecode(prefs[_valuePref]! as String) as Map)['name'],
      'Saint Wilfrid, Bishop',
    );
  });

  test('a stored entry for the same key is served with zero requests '
      '(cache read key == request key)', () async {
    final repo = await repoWith(
      respond: (request) async => throw StateError('must not be called'),
      initialPrefs: {
        _dateKeyPref: '2026-10-12',
        _valuePref: storedEntry('2026-10-12'),
      },
    );

    final saint = await repo.getTodaysSaint();

    expect(saint.name, 'Stored Saint');
    expect(requested, isEmpty);
  });

  test('a corrupt stored entry for today is a miss: it re-fetches and '
      'replaces it', () async {
    final repo = await repoWith(
      respond: (request) async => http.Response(saintJson(), 200),
      initialPrefs: {_dateKeyPref: '2026-10-12', _valuePref: '{"name": 7}'},
    );

    final saint = await repo.getTodaysSaint();

    expect(saint.name, 'Saint Wilfrid, Bishop');
    expect(requested, hasLength(1));
    final prefs = await prefsSnapshot();
    expect(
      (jsonDecode(prefs[_valuePref]! as String) as Map)['name'],
      'Saint Wilfrid, Bishop',
    );
  });

  test(
    'yesterday\'s stored entry is a miss and is replaced by today\'s',
    () async {
      final repo = await repoWith(
        respond: (request) async => http.Response(saintJson(), 200),
        initialPrefs: {
          _dateKeyPref: '2026-10-11',
          _valuePref: storedEntry('2026-10-11'),
        },
      );

      await repo.getTodaysSaint();

      expect(requested.map((u) => u.path), ['/v1/saints/2026-10-12']);
      expect((await prefsSnapshot())[_dateKeyPref], '2026-10-12');
    },
  );

  group('failures leave the stored entry byte-for-byte unchanged '
      '(REQ-F09-014)', () {
    final cases =
        <(String, Future<http.Response> Function(http.Request), Type)>[
          (
            '503 saint_not_ready',
            (r) async => http.Response(
              problemJson(status: 503, code: 'saint_not_ready'),
              503,
            ),
            SaintOfTheDayNotReadyFailure,
          ),
          (
            '404 saint_not_available',
            (r) async => http.Response(
              problemJson(status: 404, code: 'saint_not_available'),
              404,
            ),
            SaintOfTheDayDateUnavailableFailure,
          ),
          (
            '401 app_check_required',
            (r) async => http.Response(
              problemJson(status: 401, code: 'app_check_required'),
              401,
            ),
            SaintOfTheDayUnavailableFailure,
          ),
          (
            'transport error',
            (r) async => throw http.ClientException('offline'),
            SaintOfTheDayNetworkFailure,
          ),
          (
            'non-UTF-8 200 body',
            (r) async => http.Response.bytes([0xff, 0xfe], 200),
            SaintOfTheDayParsingFailure,
          ),
          (
            '200 missing a field',
            (r) async => http.Response(saintJson(without: ['prayer']), 200),
            SaintOfTheDayParsingFailure,
          ),
          (
            '200 with an empty name',
            (r) async => http.Response(saintJson(overrides: {'name': ''}), 200),
            SaintOfTheDayParsingFailure,
          ),
          (
            '200 with a malformed dateKey',
            (r) async => http.Response(saintJson(dateKey: '2026-13-01'), 200),
            SaintOfTheDayParsingFailure,
          ),
        ];

    for (final (label, respond, type) in cases) {
      test('$label -> $type', () async {
        final initial = <String, Object>{
          _dateKeyPref: '2026-10-11',
          _valuePref: storedEntry('2026-10-11'),
        };
        final repo = await repoWith(respond: respond, initialPrefs: initial);
        final before = await prefsSnapshot();

        Object? error;
        try {
          await repo.getTodaysSaint();
        } catch (e) {
          error = e;
        }

        expect(error.runtimeType, type);
        expect(await prefsSnapshot(), before);
      });
    }
  });

  test('a throwing shared_preferences write does not fail the read', () async {
    SharedPreferencesStorePlatform.instance = _ThrowingWriteStore();
    SharedPreferences.resetStatic();
    final prefs = await SharedPreferences.getInstance();
    var requests = 0;
    final repo = SaintOfTheDayRepositoryImpl(
      SaintOfTheDayRemoteDatasource(
        MockClient((request) async {
          requests++;
          return http.Response(saintJson(), 200);
        }),
        baseUri: Uri.parse('https://api.example.org'),
      ),
      SharedPreferencesSaintOfTheDayCache(prefs),
      clock: () => sydneyNow(oct12MorningUtc),
    );

    final saint = await repo.getTodaysSaint();
    expect(saint.name, 'Saint Wilfrid, Bishop');

    // Nothing was stored, so the next call pays for one more request.
    await repo.getTodaysSaint();
    expect(requests, 2);
  });

  test('rollover at Sydney midnight (AEDT, 13:00 UTC) requests the new '
      'date and replaces the stored entry', () async {
    var nowUtc = DateTime.utc(2026, 10, 12, 12, 59);
    final repo = await repoWith(
      respond: (request) async =>
          http.Response(saintJson(dateKey: request.url.pathSegments.last), 200),
      utcClock: () => nowUtc,
    );

    await repo.getTodaysSaint();
    await repo.getTodaysSaint();
    expect(requested.map((u) => u.path), ['/v1/saints/2026-10-12']);

    nowUtc = DateTime.utc(2026, 10, 12, 13);
    final next = await repo.getTodaysSaint();

    expect(requested.map((u) => u.path), [
      '/v1/saints/2026-10-12',
      '/v1/saints/2026-10-13',
    ]);
    expect(next.dateKey, '2026-10-13');
    expect((await prefsSnapshot())[_dateKeyPref], '2026-10-13');
  });

  test('a server dateKey that differs from the request is stored under '
      'the server key, so the next same-day load requests again '
      '(RISK-F09-006, accepted cost of one request)', () async {
    final repo = await repoWith(
      respond: (request) async =>
          http.Response(saintJson(dateKey: '2026-10-13'), 200),
    );

    await repo.getTodaysSaint();
    await repo.getTodaysSaint();

    expect((await prefsSnapshot())[_dateKeyPref], '2026-10-13');
    expect(requested.map((u) => u.path), [
      '/v1/saints/2026-10-12',
      '/v1/saints/2026-10-12',
    ]);
  });
}
