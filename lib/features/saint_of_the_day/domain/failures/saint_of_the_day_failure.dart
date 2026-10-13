/// Typed failures for the Saint of the Day fetch/parse pipeline. The data
/// layer converts every network/parsing/configuration problem into one of
/// these before it reaches the provider/UI, so no raw exception is ever
/// shown to the user (CLAUDE.md's error handling rules). There is one
/// subtype per user-visible message (REQ-F09-006/REQ-F09-016).
sealed class SaintOfTheDayFailure implements Exception {
  const SaintOfTheDayFailure(this.message);

  /// Diagnostic detail for logs — never shown to the end user. Includes the
  /// requested date key, HTTP status, problem `code` and `requestId` where
  /// they apply (REQ-F09-007).
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No valid parish API origin is configured (`API_BASE_URL`/`BASE_URL` in
/// assets/app.env), so no request was sent (REQ-F09-003).
final class SaintOfTheDayNotConfiguredFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayNotConfiguredFailure(super.message);
}

/// The request timed out or never reached the server (transport error).
/// The only failure that tells the user to check their connection.
final class SaintOfTheDayNetworkFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayNetworkFailure(super.message);
}

/// 503 `saint_not_ready`: the server's background job has not prepared the
/// requested day's saint yet (D-4).
final class SaintOfTheDayNotReadyFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayNotReadyFailure(super.message);
}

/// 404 (`saint_not_available`): the requested date is outside the server's
/// yesterday/today/tomorrow window, which means the device clock is more
/// than about a day off (D-8).
final class SaintOfTheDayDateUnavailableFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayDateUnavailableFailure(super.message);
}

/// Any other non-200 response: 401 `app_check_required`, 400
/// `invalid_date`, a 503 without `saint_not_ready`, other 5xx and so on
/// (D-5, D-8).
final class SaintOfTheDayUnavailableFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayUnavailableFailure(super.message);
}

/// A 200 response could not be turned into a usable [SaintOfTheDay]:
/// malformed JSON, a missing or ill-typed field, a malformed `dateKey`, an
/// empty name, or no renderable sections (REQ-F09-008/REQ-F09-009).
final class SaintOfTheDayParsingFailure extends SaintOfTheDayFailure {
  const SaintOfTheDayParsingFailure(super.message);
}
