import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:st_luke_parish_app/features/ministries/data/cache/ministries_cache.dart';

/// The on-device store behind REQ-F08-009/010.
void main() {
  Future<SharedPreferencesMinistriesCache> cacheWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferencesMinistriesCache(
      await SharedPreferences.getInstance(),
    );
  }

  test('reads null when nothing has been saved', () async {
    final cache = await cacheWith({});

    expect(await cache.read(), isNull);
  });

  test('round-trips a saved body', () async {
    final cache = await cacheWith({});

    await cache.write('{"items": []}');

    expect(await cache.read(), '{"items": []}');
  });

  test('a later write replaces the earlier one', () async {
    final cache = await cacheWith({});

    await cache.write('first');
    await cache.write('second');

    expect(await cache.read(), 'second');
  });

  test('survives a new SharedPreferences instance (app restart)', () async {
    final cache = await cacheWith({});
    await cache.write('{"items": []}');

    final reopened = SharedPreferencesMinistriesCache(
      await SharedPreferences.getInstance(),
    );

    expect(await reopened.read(), '{"items": []}');
  });
}
