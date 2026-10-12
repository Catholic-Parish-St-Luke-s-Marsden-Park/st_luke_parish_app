/// The fields this app reads from an RFC 9457 `application/problem+json`
/// error body returned by the parish API (REQ-F09-005). Every field is
/// optional: a body that omits one, or is not a problem document at all,
/// still maps by HTTP status alone.
class ProblemDetails {
  const ProblemDetails({this.status, this.code, this.title, this.requestId});

  /// The `status` member, when present and an integer.
  final int? status;

  /// The API's stable machine-readable `code`, e.g. `saint_not_ready`.
  final String? code;

  /// The short human-readable `title`. Logged only, never shown.
  final String? title;

  /// The server's `requestId`, for correlating with server logs.
  final String? requestId;
}
