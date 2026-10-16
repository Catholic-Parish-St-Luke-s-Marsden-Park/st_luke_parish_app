import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/parish/data/parsers/popup_image_parser.dart';

const _popupPage = '''
<div class="fl-module fl-module-modal-popup fl-node-6943274a9606b">
  <div class="uabb-modal-text uabb-modal-content-data">
    <img decoding="async" alt=""
      data-src="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/STD-LS-SLMP-1024x724.jpg"
      class="lazyload"
      src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" />
    <noscript><img src="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/STD-LS-SLMP-1024x724.jpg" alt=""/></noscript>
  </div>
</div>
<img src="https://stlukesmarsdenpark.org.au/logo.png" alt="Not the pop-up">
''';

const _poster =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
    'STD-LS-SLMP-1024x724.jpg';

final _base = Uri.parse('https://stlukesmarsdenpark.org.au/');

void main() {
  test("reads the pop-up image's lazy-loaded address, not the placeholder", () {
    expect(parsePopupImageUrl(_popupPage, baseUri: _base), _poster);
  });

  test('falls back to src when there is no data-src', () {
    const html =
        '<div class="fl-module-modal-popup"><img src="/notice.png"></div>';
    expect(
      parsePopupImageUrl(html, baseUri: _base),
      'https://stlukesmarsdenpark.org.au/notice.png',
    );
  });

  test('ignores images outside the pop-up', () {
    const html = '<img src="https://stlukesmarsdenpark.org.au/logo.png">';
    expect(parsePopupImageUrl(html, baseUri: _base), isNull);
  });

  test('returns null when the pop-up only has a data: placeholder', () {
    const html =
        '<div class="fl-module-modal-popup">'
        '<img src="data:image/gif;base64,R0lGOD"></div>';
    expect(parsePopupImageUrl(html, baseUri: _base), isNull);
  });

  test('returns null for empty input', () {
    expect(parsePopupImageUrl('', baseUri: _base), isNull);
  });
}
