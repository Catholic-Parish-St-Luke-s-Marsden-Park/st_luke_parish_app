import '../entities/saint_of_the_day.dart';

/// Sole access point for today's saint data. Screens/widgets read it only
/// through the presentation-layer provider that wraps this contract —
/// never by importing the datasource, parser, or cache directly.
///
/// Implementations must convert network/parsing/configuration failures into
/// a `SaintOfTheDayFailure` subtype (see `../failures/saint_of_the_day_failure.dart`)
/// rather than letting a raw exception escape.
abstract class SaintOfTheDayRepository {
  /// Returns today's saint (`Australia/Sydney` calendar day), serving a
  /// same-day cached value when available (REQ-F06-008) and otherwise
  /// calling OpenRouter, parsing the response, and caching the result
  /// before returning it (REQ-F06-009).
  Future<SaintOfTheDay> getTodaysSaint();
}
