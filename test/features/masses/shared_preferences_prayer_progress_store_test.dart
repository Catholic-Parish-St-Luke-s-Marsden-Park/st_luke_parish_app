import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:st_luke_parish_app/features/masses/data/progress/shared_preferences_prayer_progress_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(SharedPreferences.resetStatic);

  Future<SharedPreferencesPrayerProgressStore> store() async =>
      SharedPreferencesPrayerProgressStore(
        await SharedPreferences.getInstance(),
      );

  test('nothing saved yet', () async {
    expect(
      await (await store()).stepFor('rosary', DateTime(2026, 10, 19)),
      isNull,
    );
  });

  test('gives back the step for the same day, at any time', () async {
    await (await store()).save('rosary', DateTime(2026, 10, 19, 8), 34);
    // A new instance, as after the app is closed and opened again.
    SharedPreferences.resetStatic();
    expect(
      await (await store()).stepFor('rosary', DateTime(2026, 10, 19, 22)),
      34,
    );
  });

  test('forgets it on another day', () async {
    final s = await store();
    await s.save('rosary', DateTime(2026, 10, 19), 34);
    expect(await s.stepFor('rosary', DateTime(2026, 10, 20)), isNull);
    expect(await s.stepFor('rosary', DateTime(2025, 10, 19)), isNull);
  });

  test('keeps each prayer apart', () async {
    final s = await store();
    await s.save('rosary', DateTime(2026, 10, 19), 34);
    await s.save('divine_mercy_chaplet', DateTime(2026, 10, 19), 7);
    expect(await s.stepFor('rosary', DateTime(2026, 10, 19)), 34);
    expect(await s.stepFor('divine_mercy_chaplet', DateTime(2026, 10, 19)), 7);
  });

  test('ignores a damaged saved value', () async {
    SharedPreferences.setMockInitialValues({
      'prayer_progress.rosary': 'not a step',
    });
    expect(
      await (await store()).stepFor('rosary', DateTime(2026, 10, 19)),
      isNull,
    );
  });
}
