import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/resources/data/parsers/monthly_reflections_parser.dart';

const _page = '''
<html><body>
<h2>On Our Knees</h2><h3>Monthly</h3>
<a href="https://www.risenlordcommunity.com/_files/ugd/five-pillars.pdf">The Five Pillars</a>
<h3>2026</h3>
<p><a href="https://www.risenlordcommunity.com/_files/ugd/sep.pdf">September 2026</a></p>
<p><a href="https://www.risenlordcommunity.com/_files/ugd/aug.pdf">August  2026</a></p>
<p><a href="https://www.risenlordcommunity.com/_files/ugd/oct.pdf"><span>October 2026</span></a></p>
<p>TBA</p>
<h3>2025</h3>
<p><a href="/_files/ugd/dec25.pdf">December 2025</a></p>
</body></html>
''';

final _base = Uri.parse('https://www.risenlordcommunity.com/onyourknees');

void main() {
  test('reads every "Month YYYY" link, in page order, ignoring others', () {
    final reflections = parseMonthlyReflections(_page, baseUri: _base);

    expect(reflections.map((r) => r.label), [
      'September 2026',
      'August 2026',
      'October 2026',
      'December 2025',
    ]);
    expect(reflections.map((r) => r.month), [
      DateTime(2026, 9),
      DateTime(2026, 8),
      DateTime(2026, 10),
      DateTime(2025, 12),
    ]);
  });

  test('resolves a relative link against the page', () {
    final december = parseMonthlyReflections(
      _page,
      baseUri: _base,
    ).singleWhere((r) => r.month == DateTime(2025, 12));
    expect(
      december.url,
      'https://www.risenlordcommunity.com/_files/ugd/dec25.pdf',
    );
  });

  test('matches month names case-insensitively', () {
    final reflections = parseMonthlyReflections(
      '<a href="/x.pdf">NOVEMBER 2026</a>',
      baseUri: _base,
    );
    expect(reflections.single.month, DateTime(2026, 11));
  });

  test('ignores labels that only contain a month, and empty links', () {
    expect(
      parseMonthlyReflections(
        '<a href="/a.pdf">Reflections for October 2026</a>'
        '<a href="  ">October 2026</a>'
        '<a href="/b.pdf">October</a>',
        baseUri: _base,
      ),
      isEmpty,
    );
  });

  test('returns nothing for empty input', () {
    expect(parseMonthlyReflections('', baseUri: _base), isEmpty);
  });
}
