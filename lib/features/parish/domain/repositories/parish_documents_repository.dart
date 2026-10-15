import '../entities/parish_document_links.dart';

/// Sole access point for parish documents linked from the parish website.
///
/// Implementations throw a `ParishDocumentsFailure` subtype rather than
/// letting a raw exception escape.
abstract class ParishDocumentsRepository {
  /// The Pastoral Plan and latest Pastoral Council minutes links, read
  /// from the parish home page in one request.
  Future<ParishDocumentLinks> getDocumentLinks();
}
