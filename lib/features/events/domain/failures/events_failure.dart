/// Typed failures for the events fetch/parse pipeline (REQ-F08-010,
/// REQ-F08-011). `FeedEventsRepository` converts every network/parsing
/// exception into one of these before it reaches the provider/UI, so no raw
/// exception/stack trace is ever surfaced to the user (CLAUDE.md's error
/// handling rules) — mirrors `BulletinsFailure`'s shape from the News
/// feature exactly.
sealed class EventsFailure implements Exception {
  const EventsFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The feed could not be reached, timed out, or returned a non-2xx status.
final class EventsNetworkFailure extends EventsFailure {
  const EventsNetworkFailure(super.message);
}

/// The feed response could not be parsed as the expected iCalendar shape at
/// all (REQ-F08-011) — distinct from an individually-skipped malformed
/// `VEVENT` block (REQ-F08-004), which does not raise this failure.
final class EventsParsingFailure extends EventsFailure {
  const EventsParsingFailure(super.message);
}
