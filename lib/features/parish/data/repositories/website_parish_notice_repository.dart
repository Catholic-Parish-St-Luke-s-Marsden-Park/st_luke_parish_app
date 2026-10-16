import 'dart:developer' as developer;

import '../../../../core/constants/external_links.dart';
import '../../domain/entities/parish_notice.dart';
import '../../domain/failures/parish_documents_failure.dart';
import '../../domain/repositories/parish_notice_repository.dart';
import '../datasources/parish_home_page_datasource.dart';
import '../parsers/popup_image_parser.dart';
import '../selectors/parish_home_selectors.dart';

/// Reads the parish home page's pop-up, so the app's floating announcement
/// button shows whatever the parish currently has there.
class WebsiteParishNoticeRepository implements ParishNoticeRepository {
  WebsiteParishNoticeRepository(this._datasource);

  final ParishHomePageDatasource _datasource;

  @override
  Future<ParishNotice?> getCurrentNotice() async {
    try {
      final html = await _datasource.fetchHomePageHtml();
      final url = parsePopupImageUrl(
        html,
        baseUri: Uri.parse(ExternalLinks.parishHomePage),
      );
      if (url == null) {
        _log('No "${ParishHomeSelectors.popupImageKey}" on the home page');
        return null;
      }
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !(uri.scheme == 'https' || uri.scheme == 'http') ||
          uri.host.isEmpty) {
        throw ParishDocumentsParsingFailure(
          'Pop-up image is not a valid web link: $url',
        );
      }
      return ParishNotice(imageUrl: url);
    } on ParishDocumentsFailure catch (e) {
      _log('$e');
      rethrow;
    } catch (e) {
      final failure = ParishDocumentsParsingFailure(
        'Unexpected error reading the home page pop-up: $e',
      );
      _log('$failure');
      throw failure;
    }
  }

  void _log(String message) =>
      developer.log(message, name: 'ParishNoticeRepository');
}
