import 'package:html/parser.dart' as html_parser;

import '../selectors/parish_home_selectors.dart';

/// The address of the image in the parish home page's pop-up, resolved
/// against [baseUri], or `null` when the page has no pop-up image.
///
/// Lazy-loaded images carry a 1x1 `data:` placeholder in `src`, so
/// `data-src` is read first and `data:` addresses are skipped.
String? parsePopupImageUrl(String html, {required Uri baseUri}) {
  final document = html_parser.parse(html);
  for (final image in document.querySelectorAll(
    ParishHomeSelectors.popupImage,
  )) {
    for (final attribute in ParishHomeSelectors.popupImageAttributes) {
      final value = image.attributes[attribute]?.trim();
      if (value == null || value.isEmpty || value.startsWith('data:')) {
        continue;
      }
      final uri = Uri.tryParse(value);
      if (uri == null) continue;
      return baseUri.resolveUri(uri).toString();
    }
  }
  return null;
}
