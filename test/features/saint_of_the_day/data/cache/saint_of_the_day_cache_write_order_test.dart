import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/cache/saint_of_the_day_cache.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';

/// Pins the commit-last write ordering in
/// [SharedPreferencesSaintOfTheDayCache].
///
/// `read` matches on the standalone date key, so that key must be written
/// *after* the value it points at. If the order is reversed, a process
/// killed between the two writes leaves today's key pointing at
/// yesterday's cached saint — which decodes cleanly and is served as a
/// silent `AsyncData` success for the rest of the day.
///
/// The invariant is about the *order of the two writes*, which no
/// after-the-fact assertion on stored values can observe. These tests use
/// a recording store to see the calls themselves.
class _RecordingStore extends SharedPreferencesStorePlatform {
  _RecordingStore({this.failOnKeySuffix});

  /// When set, `setValue` returns false for the key ending with this
  /// suffix, simulating a platform write failure.
  final String? failOnKeySuffix;

  final Map<String, Object> _store = {};

  /// Keys passed to `setValue`, in call order, with the legacy
  /// `flutter.` prefix stripped.
  final List<String> writes = [];

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final bare = key.replaceFirst('flutter.', '');
    writes.add(bare);
    if (failOnKeySuffix != null && bare.endsWith(failOnKeySuffix!)) {
      return false;
    }
    _store[key] = value;
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_store);

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async => Map.of(_store);

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    _store.clear();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const saint = SaintOfTheDay(
    name: 'Saint Example',
    feast: 'A feast',
    bornDied: 'Born, died',
    about: 'About text',
    saying: 'A saying',
    didYouKnow: 'A fact',
    patronOf: 'Something',
    prayer: 'A prayer',
    dateKey: '2026-09-01',
    displayDate: 'September 1',
  );

  const valueKey = 'saint_of_the_day_cache_value';
  const dateKeyKey = 'saint_of_the_day_cache_date_key';

  Future<SharedPreferencesSaintOfTheDayCache> cacheBackedBy(
    _RecordingStore store,
  ) async {
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesSaintOfTheDayCache(prefs);
  }

  tearDown(SharedPreferences.resetStatic);

  test('write stores the value before the date key that reads it', () async {
    final store = _RecordingStore();
    final cache = await cacheBackedBy(store);

    await cache.write('2026-09-01', saint);

    expect(store.writes, [valueKey, dateKeyKey]);
  });

  test('a failed value write does not commit the date key', () async {
    // Half-committing would leave the date key advertising an entry that
    // was never stored. Better to leave the cache as it was and miss.
    final store = _RecordingStore(failOnKeySuffix: valueKey);
    final cache = await cacheBackedBy(store);

    await cache.write('2026-09-01', saint);

    expect(store.writes, [valueKey]);
    expect(store.writes, isNot(contains(dateKeyKey)));
  });
}
