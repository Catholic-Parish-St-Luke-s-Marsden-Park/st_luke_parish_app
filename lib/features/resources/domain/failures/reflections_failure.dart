/// Typed failures for finding the monthly Daily Readings & Reflections.
sealed class ReflectionsFailure implements Exception {
  const ReflectionsFailure(this.message);

  /// Diagnostic detail for logs — not shown to the end user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The page could not be reached, timed out, or returned a non-200 status.
final class ReflectionsNetworkFailure extends ReflectionsFailure {
  const ReflectionsNetworkFailure(super.message);
}

/// The page loaded, but no monthly booklet links were found on it.
final class ReflectionsParsingFailure extends ReflectionsFailure {
  const ReflectionsParsingFailure(super.message);
}
