import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/parish/data/parsers/labelled_link_parser.dart';
import 'package:st_luke_parish_app/features/parish/data/selectors/parish_home_selectors.dart';

const _homePage = '''
<html><body>
<div class="fl-button-wrap">
  <a href="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/Parish-Pastoral-Plan-2026-2028.pdf" class="fl-button" role="button">
    <span class="fl-button-text">Parish Pastoral Plan 2026-2028</span>
  </a>
</div>
<div class="fl-button-wrap">
  <a href="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/10/17-October-2026-Parish-Pastoral-Council-Meeting-Minutes.pdf" download class="fl-button" role="button">
    <span class="fl-button-text">Parish Pastoral Council Meeting Minutes</span>
  </a>
</div>
</body></html>
''';

const _latestMinutes =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/10/'
    '17-October-2026-Parish-Pastoral-Council-Meeting-Minutes.pdf';

final _base = Uri.parse('https://stlukesmarsdenpark.org.au/');
const _minutes = ParishHomeSelectors.pastoralCouncilMinutesUrl;

void main() {
  group('parseLabelledLink — Pastoral Council minutes', () {
    test('returns the minutes link, not the Pastoral Plan link', () {
      expect(
        parseLabelledLink(_homePage, _minutes, baseUri: _base),
        _latestMinutes,
      );
    });

    test('matches the label case-insensitively and across whitespace', () {
      const html = '''
<a href="/wp-content/uploads/m.pdf"><span>PARISH  PASTORAL
  COUNCIL</span> meeting MINUTES</a>''';
      expect(
        parseLabelledLink(html, _minutes, baseUri: _base),
        'https://stlukesmarsdenpark.org.au/wp-content/uploads/m.pdf',
      );
    });

    test('resolves a relative link against the home page', () {
      const html = '<a href="minutes.pdf">Pastoral Council Minutes</a>';
      expect(
        parseLabelledLink(html, _minutes, baseUri: _base),
        'https://stlukesmarsdenpark.org.au/minutes.pdf',
      );
    });

    test('returns null when no link carries the label', () {
      const html = '<a href="/plan.pdf">Parish Pastoral Plan</a>';
      expect(parseLabelledLink(html, _minutes, baseUri: _base), isNull);
    });

    test('skips a matching link with an empty href', () {
      const html = '''
<a href="  ">Pastoral Council Minutes</a>
<a href="/real.pdf">Pastoral Council Minutes</a>''';
      expect(
        parseLabelledLink(html, _minutes, baseUri: _base),
        'https://stlukesmarsdenpark.org.au/real.pdf',
      );
    });

    test('returns null for empty or non-HTML input', () {
      expect(parseLabelledLink('', _minutes, baseUri: _base), isNull);
      expect(
        parseLabelledLink('not html at all', _minutes, baseUri: _base),
        isNull,
      );
    });
  });
}
