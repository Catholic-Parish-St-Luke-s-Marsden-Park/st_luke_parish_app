/// Where the step reached in a prayer said bead by bead (the Rosary, the
/// Chaplet) is kept on the phone, so someone who stops partway can carry on
/// later the same day (parish request, 2026-10-19).
abstract interface class PrayerProgressStore {
  /// The step reached in [prayer] on [day], or null if nothing was saved
  /// for that day.
  Future<int?> stepFor(String prayer, DateTime day);

  /// Remembers [step] as the step reached in [prayer] on [day].
  Future<void> save(String prayer, DateTime day, int step);
}
