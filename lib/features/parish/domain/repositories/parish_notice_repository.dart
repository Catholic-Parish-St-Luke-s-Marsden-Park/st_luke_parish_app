import '../entities/parish_notice.dart';

/// Sole access point for the parish home page's pop-up notice.
///
/// Implementations throw a `ParishDocumentsFailure` subtype rather than
/// letting a raw exception escape.
abstract class ParishNoticeRepository {
  /// The current pop-up notice, or `null` when the home page has none.
  Future<ParishNotice?> getCurrentNotice();
}
