/// Typed failures for the ministries fetch/parse pipeline. The data layer
/// converts every network/parsing/configuration exception into one of these
/// before it reaches the provider/UI, so no raw exception is ever shown to
/// the user (CLAUDE.md's error handling rules).
sealed class MinistriesFailure implements Exception {
  const MinistriesFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No valid parish API origin is configured (`API_BASE_URL`/`BASE_URL` in
/// assets/app.env), so no request was sent.
final class MinistriesNotConfiguredFailure extends MinistriesFailure {
  const MinistriesNotConfiguredFailure(super.message);
}

/// The API could not be reached, timed out, or returned a non-200 status.
final class MinistriesNetworkFailure extends MinistriesFailure {
  const MinistriesNetworkFailure(super.message);
}

/// The response (or a cached/bundled copy of it) could not be turned into
/// ministries: invalid JSON, or a missing or ill-typed field.
final class MinistriesParsingFailure extends MinistriesFailure {
  const MinistriesParsingFailure(super.message);
}

/// `GET /v1/ministries/{id}` returned 404: the id is unknown or hidden.
final class MinistryNotFoundFailure extends MinistriesFailure {
  const MinistryNotFoundFailure(super.message);
}
