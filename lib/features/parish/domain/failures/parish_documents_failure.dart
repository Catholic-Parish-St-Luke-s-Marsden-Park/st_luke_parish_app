/// Typed failures for finding parish documents (such as the latest
/// Pastoral Council minutes) on the parish website. The repository converts
/// every network/parsing problem into one of these.
sealed class ParishDocumentsFailure implements Exception {
  const ParishDocumentsFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The page could not be reached, timed out, or returned a non-200 status.
final class ParishDocumentsNetworkFailure extends ParishDocumentsFailure {
  const ParishDocumentsNetworkFailure(super.message);
}

/// The page loaded, but none of the expected links were found.
final class ParishDocumentsParsingFailure extends ParishDocumentsFailure {
  const ParishDocumentsParsingFailure(super.message);
}
