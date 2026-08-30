/// Typed failures for the bulletins fetch/parse pipeline (REQ-F05-012,
/// REQ-F05-013). `FeedBulletinsRepository` converts every network/parsing
/// exception into one of these before it reaches the provider/UI, so no raw
/// exception/stack trace is ever surfaced to the user (CLAUDE.md's error
/// handling rules) — the UI distinguishes network vs. parsing failures by
/// `error is BulletinsNetworkFailure`/`error is BulletinsParsingFailure`.
sealed class BulletinsFailure implements Exception {
  const BulletinsFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The feed could not be reached, timed out, or returned a non-2xx status.
final class BulletinsNetworkFailure extends BulletinsFailure {
  const BulletinsNetworkFailure(super.message);
}

/// The feed response could not be parsed as the expected RSS/XML shape.
final class BulletinsParsingFailure extends BulletinsFailure {
  const BulletinsParsingFailure(super.message);
}
