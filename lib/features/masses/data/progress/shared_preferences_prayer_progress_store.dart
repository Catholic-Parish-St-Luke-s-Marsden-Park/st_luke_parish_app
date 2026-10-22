import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/prayer_progress_store.dart';

/// [PrayerProgressStore] in SharedPreferences: one entry per prayer, holding
/// the day and the step, e.g. `2026-10-19:34`. Only the latest day is kept,
/// so a new day starts the prayer from the beginning.
class SharedPreferencesPrayerProgressStore implements PrayerProgressStore {
  SharedPreferencesPrayerProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String prayer) => 'prayer_progress.$prayer';

  static String _dayOf(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  Future<int?> stepFor(String prayer, DateTime day) async {
    final saved = _prefs.getString(_key(prayer));
    if (saved == null) return null;
    final separator = saved.lastIndexOf(':');
    if (separator < 0 || saved.substring(0, separator) != _dayOf(day)) {
      return null;
    }
    return int.tryParse(saved.substring(separator + 1));
  }

  @override
  Future<void> save(String prayer, DateTime day, int step) async {
    await _prefs.setString(_key(prayer), '${_dayOf(day)}:$step');
  }
}
