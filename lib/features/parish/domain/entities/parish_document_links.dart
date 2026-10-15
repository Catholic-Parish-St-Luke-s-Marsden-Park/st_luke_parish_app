/// Links to parish documents found on the parish home page. A field is
/// `null` when that link wasn't found, so the app can fall back to the copy
/// it ships with for just that one.
class ParishDocumentLinks {
  const ParishDocumentLinks({this.pastoralPlanUrl, this.councilMinutesUrl});

  /// The Parish Pastoral Plan PDF.
  final String? pastoralPlanUrl;

  /// The latest Parish Pastoral Council meeting minutes.
  final String? councilMinutesUrl;
}
