import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/cache/saint_of_the_day_cache.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';

/// Covers REQ-F06-008/REQ-F06-009/REQ-F06-010: date-keyed read/write and
/// same-day-only retention.
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

  Future<SharedPreferencesSaintOfTheDayCache> makeCache() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesSaintOfTheDayCache(prefs);
  }

  test('read returns null on a completely empty cache', () async {
    final cache = await makeCache();

    expect(await cache.read('2026-09-01'), isNull);
  });

  test('write then read with the same date key returns the value', () async {
    final cache = await makeCache();

    await cache.write('2026-09-01', saint);
    final result = await cache.read('2026-09-01');

    expect(result, isNotNull);
    expect(result!.name, 'Saint Example');
    expect(result.dateKey, '2026-09-01');
  });

  test(
    'read returns null for a different date key (cache miss on day rollover)',
    () async {
      final cache = await makeCache();
      await cache.write('2026-09-01', saint);

      final result = await cache.read('2026-09-02');

      expect(result, isNull);
    },
  );

  test('writing a new date key supersedes the old one (REQ-F06-009)', () async {
    final cache = await makeCache();
    await cache.write('2026-09-01', saint);

    const tomorrow = SaintOfTheDay(
      name: 'Saint Tomorrow',
      feast: '',
      bornDied: '',
      about: '',
      saying: '',
      didYouKnow: '',
      patronOf: '',
      prayer: '',
      dateKey: '2026-09-02',
      displayDate: 'September 2',
    );
    await cache.write('2026-09-02', tomorrow);

    expect(await cache.read('2026-09-01'), isNull);
    final result = await cache.read('2026-09-02');
    expect(result?.name, 'Saint Tomorrow');
  });

  group('commit-last write ordering', () {
    test('the value is written before the date key it is read by', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = SharedPreferencesSaintOfTheDayCache(prefs);

      await cache.write('2026-09-01', saint);

      // Both keys are present after a complete write; the ordering only
      // matters for what an *interrupted* write leaves behind, which the
      // next two tests cover.
      expect(prefs.getString('saint_of_the_day_cache_value'), isNotNull);
      expect(prefs.getString('saint_of_the_day_cache_date_key'), '2026-09-01');
    });

    test(
      'an interrupted write cannot serve yesterday under today\'s key',
      () async {
        // Simulates a process killed between the two writes under the old
        // key-first ordering: the date key says today, the stored value is
        // still yesterday's. That entry must never be served.
        SharedPreferences.setMockInitialValues({
          'saint_of_the_day_cache_date_key': '2026-09-02',
          'saint_of_the_day_cache_value': jsonEncode({
            'name': 'Yesterday Saint',
            'feast': '',
            'bornDied': '',
            'about': 'Stale content',
            'saying': '',
            'didYouKnow': '',
            'patronOf': '',
            'prayer': '',
            'dateKey': '2026-09-01',
            'displayDate': 'September 1',
          }),
        });
        final prefs = await SharedPreferences.getInstance();
        final cache = SharedPreferencesSaintOfTheDayCache(prefs);

        expect(await cache.read('2026-09-02'), isNull);
      },
    );

    test('an interrupted write leaves a clean miss, not a stale hit', () async {
      // Under commit-last, the failure window leaves the *old* date key
      // beside the new value — which simply does not match today, so the
      // next read misses and re-fetches.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = SharedPreferencesSaintOfTheDayCache(prefs);
      await cache.write('2026-09-01', saint);

      // The value for the new day lands, but the process dies before the
      // date key is committed.
      await prefs.setString(
        'saint_of_the_day_cache_value',
        jsonEncode({
          'name': 'Today Saint',
          'feast': '',
          'bornDied': '',
          'about': 'Fresh content',
          'saying': '',
          'didYouKnow': '',
          'patronOf': '',
          'prayer': '',
          'dateKey': '2026-09-02',
          'displayDate': 'September 2',
        }),
      );

      expect(await cache.read('2026-09-02'), isNull);
    });
  });

  test('a corrupted cache entry is treated as a miss, not a crash', () async {
    SharedPreferences.setMockInitialValues({
      'saint_of_the_day_cache_date_key': '2026-09-01',
      'saint_of_the_day_cache_value': 'not valid json',
    });
    final prefs = await SharedPreferences.getInstance();
    final cache = SharedPreferencesSaintOfTheDayCache(prefs);

    expect(await cache.read('2026-09-01'), isNull);
  });
}
