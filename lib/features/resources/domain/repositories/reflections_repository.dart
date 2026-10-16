import '../entities/monthly_reflection.dart';

/// Sole access point for the monthly Daily Readings & Reflections.
///
/// Implementations throw a `ReflectionsFailure` subtype rather than letting
/// a raw exception escape.
abstract class ReflectionsRepository {
  /// This month's booklet, or the newest one listed if this month's isn't
  /// published yet.
  Future<MonthlyReflection> getLatestReflection();
}
