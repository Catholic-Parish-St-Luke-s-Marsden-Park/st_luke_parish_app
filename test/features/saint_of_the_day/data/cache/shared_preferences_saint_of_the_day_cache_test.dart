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
