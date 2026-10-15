import 'dart:developer' as developer;

import '../../../../core/constants/external_links.dart';
import '../../domain/failures/parish_documents_failure.dart';
import '../../domain/repositories/parish_documents_repository.dart';
import '../datasources/parish_home_page_datasource.dart';
import '../parsers/labelled_link_parser.dart';
import '../selectors/parish_home_selectors.dart';

/// Reads the parish home page and finds the Pastoral Council minutes button
/// the parish updates after each meeting, so the app always opens the
/// latest minutes.
class WebsiteParishDocumentsRepository implements ParishDocumentsRepository {
  WebsiteParishDocumentsRepository(this._datasource);

  final ParishHomePageDatasource _datasource;

  @override
  Future<String> getLatestCouncilMinutesUrl() async {
    const selector = ParishHomeSelectors.pastoralCouncilMinutesUrl;
    try {
      final html = await _datasource.fetchHomePageHtml();
      final url = parseLabelledLink(
        html,
        selector,
        baseUri: Uri.parse(ExternalLinks.parishHomePage),
      );
      if (url == null) {
        throw ParishDocumentsParsingFailure(
          'No link matching "${selector.key}" on the parish home page',
        );
      }
      if (!_isValidUrl(url)) {
        throw ParishDocumentsParsingFailure(
          '"${selector.key}" is not a valid web link: $url',
        );
      }
      return url;
    } on ParishDocumentsFailure catch (e) {
      _log('$e');
      rethrow;
    } catch (e) {
      final failure = ParishDocumentsParsingFailure(
        'Unexpected error reading the parish home page: $e',
      );
      _log('$failure');
      throw failure;
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  void _log(String message) =>
      developer.log(message, name: 'ParishDocumentsRepository');
}
