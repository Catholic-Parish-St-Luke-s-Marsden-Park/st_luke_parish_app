import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/parsers/saint_text_parser.dart';

/// Covers REQ-F06-006: tolerant regex-section extraction, ported from the
/// reference implementation's `saint_parser.dart`.
void main() {
  const fullResponse = '''
**SAINT NAME:**
Saint John Vianney, Priest

**FEAST DAY:**
August 4 - Optional Memorial

**BORN & DIED:**
1786, Dardilly, France - 1859, Ars, France

**ABOUT:**
He served as a parish priest known for his dedication to hearing confessions.

**FAMOUS SAYING:**
"The Church has three walls: the confessional, the altar, and the pulpit."

**DID YOU KNOW:**
He is the patron saint of parish priests.

**PATRON OF:**
Parish priests, confessors

**PRAYER:**
Saint John Vianney, pray for us that we may love the Sacrament of Confession.
''';

  test('extracts every section when all are present', () {
    final parsed = parseSaintText(fullResponse);

    expect(parsed.name, 'Saint John Vianney, Priest');
    expect(parsed.feast, 'August 4 - Optional Memorial');
    expect(parsed.bornDied, '1786, Dardilly, France - 1859, Ars, France');
    expect(
      parsed.about,
      'He served as a parish priest known for his dedication to hearing confessions.',
    );
    expect(
      parsed.saying,
      '"The Church has three walls: the confessional, the altar, and the pulpit."',
    );
    expect(parsed.didYouKnow, 'He is the patron saint of parish priests.');
    expect(parsed.patronOf, 'Parish priests, confessors');
    expect(
      parsed.prayer,
      'Saint John Vianney, pray for us that we may love the Sacrament of Confession.',
    );
  });

  test('missing "SAINT NAME" section defaults to "Saint of the Day"', () {
    const text = '**FEAST DAY:**\nSome feast\n';

    final parsed = parseSaintText(text);

    expect(parsed.name, 'Saint of the Day');
    expect(parsed.feast, 'Some feast');
  });

  test('every other missing section defaults to an empty string', () {
    const text = '**SAINT NAME:**\nSaint Example\n';

    final parsed = parseSaintText(text);

    expect(parsed.name, 'Saint Example');
    expect(parsed.feast, '');
    expect(parsed.bornDied, '');
    expect(parsed.about, '');
    expect(parsed.saying, '');
    expect(parsed.didYouKnow, '');
    expect(parsed.patronOf, '');
    expect(parsed.prayer, '');
  });

  test('completely malformed text (no recognisable headers) is tolerated', () {
    const text = 'The model said something unexpected with no structure.';

    final parsed = parseSaintText(text);

    expect(parsed.name, 'Saint of the Day');
    expect(parsed.about, '');
  });

  test('is case-insensitive on section labels', () {
    const text = '**saint name:**\nSaint Lower Case\n';

    final parsed = parseSaintText(text);

    expect(parsed.name, 'Saint Lower Case');
  });

  group('bold emphasis inside a section body', () {
    // The terminator used to be `(?=\*\*[A-Z])` under
    // `caseSensitive: false`, where `[A-Z]` also matches lowercase — so
    // any `**...**` emphasis inside a body ended the match there and
    // silently dropped the rest of the section. Section headers are
    // distinguished by their trailing colon, not by being bold.
    test('does not truncate the section at emphasised text', () {
      const text = '''
**SAINT NAME:**
Saint Thérèse of Lisieux

**ABOUT:**
She was declared a **Doctor of the Church** in 1997, one of only four women so honoured.

**PRAYER:**
A short prayer.
''';

      final parsed = parseSaintText(text);

      expect(parsed.about, contains('Doctor of the Church'));
      expect(parsed.about, contains('one of only four women so honoured.'));
      expect(parsed.prayer, 'A short prayer.');
    });

    test('still stops at the next real section header', () {
      const text = '''
**ABOUT:**
Body text here.

**PRAYER:**
A short prayer.
''';

      final parsed = parseSaintText(text);

      expect(parsed.about, 'Body text here.');
      expect(parsed.prayer, 'A short prayer.');
    });

    test('emphasis in the final section runs to the end of the text', () {
      const text = '**PRAYER:**\nLord, through **Saint Luke**, hear us.\n';

      final parsed = parseSaintText(text);

      expect(parsed.prayer, 'Lord, through **Saint Luke**, hear us.');
    });
  });
}
