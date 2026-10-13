import '../entities/parish_event.dart';

/// Sole access point for parish event data (REQ-F08-009). Screens/widgets
/// read events only through the presentation-layer provider that wraps this
/// contract — never by importing a datasource or parser directly.
///
/// Implementations must convert network/parsing failures into an
/// [EventsFailure] subtype (see `../failures/events_failure.dart`) rather
/// than letting a raw exception escape.
abstract class EventsRepository {
  /// Fetches, parses, validates, expands recurring occurrences, filters out
  /// past events, and sorts ascending by start — the single full
  /// upcoming-events list that both the inline 7-day section and the All
  /// Events screen read from (REQ-F08-005, REQ-F08-006).
  Future<List<ParishEvent>> getUpcomingEvents();
}
