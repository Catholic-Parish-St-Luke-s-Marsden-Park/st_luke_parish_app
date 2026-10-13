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
  /// same-day cached value when available (REQ-F09-011) and otherwise
  /// fetching it from the parish API's `GET /v1/saints/{date}` and caching
  /// the result before returning it (REQ-F09-012).
  Future<SaintOfTheDay> getTodaysSaint();
}
