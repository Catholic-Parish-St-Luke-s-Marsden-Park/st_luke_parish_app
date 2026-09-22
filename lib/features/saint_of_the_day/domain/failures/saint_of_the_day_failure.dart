/// Typed failures for the Saint of the Day fetch/parse pipeline. The
/// repository converts every network/parsing/configuration exception into
/// one of these before it reaches the provider/UI, so no raw
/// exception/stack trace is ever surfaced to the user (CLAUDE.md's error
/// handling rules) — the UI distinguishes failure kinds by
/// `error is SaintOfTheDayNetworkFailure` etc.
sealed class SaintOfTheDayFailure implements Exception {
  const SaintOfTheDayFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user. Never
  /// includes the API key or full request headers (CLAUDE.md: "do not log
  /// secrets or sensitive data").
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// `OPENROUTER_API_KEY` was not supplied at build/run time
/// (`String.fromEnvironment` returned an empty string) — REQ-F06-003. No
/// request is sent in this case.
final class SaintOfTheDayNotConfiguredFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayNotConfiguredFailure(super.message);
}

/// OpenRouter could not be reached, the request timed out, or it returned a
/// non-2xx status (REQ-F06-004/REQ-F06-005).
final class SaintOfTheDayNetworkFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayNetworkFailure(super.message);
}

/// The response contained no usable content, or its content could not be
/// turned into a usable [SaintOfTheDay] (REQ-F06-007).
final class SaintOfTheDayParsingFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayParsingFailure(super.message);
}
