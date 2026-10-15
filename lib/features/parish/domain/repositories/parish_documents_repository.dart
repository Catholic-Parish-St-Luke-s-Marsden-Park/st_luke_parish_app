/// Sole access point for parish documents linked from the parish website.
///
/// Implementations throw a `ParishDocumentsFailure` subtype rather than
/// letting a raw exception escape.
abstract class ParishDocumentsRepository {
  /// The URL of the latest Parish Pastoral Council meeting minutes, as
  /// linked from the parish home page.
  Future<String> getLatestCouncilMinutesUrl();
}
