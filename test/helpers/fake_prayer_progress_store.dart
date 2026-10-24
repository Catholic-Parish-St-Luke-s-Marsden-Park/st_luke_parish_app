import 'package:st_luke_parish_app/features/masses/domain/repositories/prayer_progress_store.dart';

/// An in-memory [PrayerProgressStore] for widget tests, so they never touch
/// the phone's real SharedPreferences.
class FakePrayerProgressStore implements PrayerProgressStore {
  /// Saved steps by prayer, with the day they were saved for.
  final Map<String, (DateTime, int)> saved = {};

  @override
  Future<int?> stepFor(String prayer, DateTime day) async {
    final entry = saved[prayer];
    if (entry == null || !_sameDay(entry.$1, day)) return null;
    return entry.$2;
  }

  @override
  Future<void> save(String prayer, DateTime day, int step) async {
    saved[prayer] = (day, step);
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
