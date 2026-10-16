import 'dart:developer' as developer;

import '../../../../core/constants/external_links.dart';
import '../../domain/entities/parish_document_links.dart';
import '../../domain/failures/parish_documents_failure.dart';
import '../../domain/repositories/parish_documents_repository.dart';
import '../datasources/parish_home_page_datasource.dart';
import '../parsers/labelled_link_parser.dart';
import '../selectors/parish_home_selectors.dart';

/// Reads the parish home page and finds the Pastoral Plan and Pastoral
/// Council minutes buttons the parish keeps up to date, so the app always
/// opens the current documents.
class WebsiteParishDocumentsRepository implements ParishDocumentsRepository {
  WebsiteParishDocumentsRepository(this._datasource);

  final ParishHomePageDatasource _datasource;

  @override
  Future<ParishDocumentLinks> getDocumentLinks() async {
    try {
      final html = await _datasource.fetchHomePageHtml();
      final links = ParishDocumentLinks(
        pastoralPlanUrl: _find(html, ParishHomeSelectors.pastoralPlanUrl),
        councilMinutesUrl: _find(
          html,
          ParishHomeSelectors.pastoralCouncilMinutesUrl,
        ),
      );
      if (links.pastoralPlanUrl == null && links.councilMinutesUrl == null) {
        throw const ParishDocumentsParsingFailure(
          'No Pastoral Plan or Pastoral Council minutes link on the parish '
          'home page',
        );
      }
      return links;
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

  /// The [selector]'s link, or `null` (logged) if it is missing or not a
  /// web address — the other link may still be fine.
  String? _find(String html, LabelledLinkSelector selector) {
    final url = parseLabelledLink(
      html,
      selector,
      baseUri: Uri.parse(ExternalLinks.parishHomePage),
    );
    if (url == null) {
      _log('No link matching "${selector.key}" on the parish home page');
      return null;
    }
    if (!_isValidUrl(url)) {
      _log('"${selector.key}" is not a valid web link: $url');
      return null;
    }
    return url;
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
