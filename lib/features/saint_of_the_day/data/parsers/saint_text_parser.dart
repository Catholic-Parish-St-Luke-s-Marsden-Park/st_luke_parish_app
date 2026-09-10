/// Fields extracted from the model's raw labelled-section text response.
/// Intermediate DTO shape used only within `data/`; the repository maps
/// this into the immutable `SaintOfTheDay` domain entity (adding
/// `dateKey`/`displayDate`, which this parser has no knowledge of).
class ParsedSaintText {
  const ParsedSaintText({
    required this.name,
    required this.feast,
    required this.bornDied,
    required this.about,
    required this.saying,
    required this.didYouKnow,
    required this.patronOf,
    required this.prayer,
  });

  final String name;
  final String feast;
  final String bornDied;
  final String about;
  final String saying;
  final String didYouKnow;
  final String patronOf;
  final String prayer;
}

/// Extracts one labelled section (e.g. `**FEAST DAY:**`) from [text],
/// returning the trimmed content up to the next `**LABEL**` header or the
/// end of the string. Ported from the reference Flutter prototype's
/// `saint_parser.dart` — same regex, same tolerant "missing section ->
/// empty string" behaviour (REQ-F06-006).
String _extractSection(String text, String label) {
  final regex = RegExp(
    '\\*\\*$label:\\*\\*\\s*([\\s\\S]*?)(?=\\*\\*[A-Z]|\$)',
    caseSensitive: false,
  );
  final match = regex.firstMatch(text);
  return match != null ? match.group(1)!.trim() : '';
}

/// Parses the model's raw text response into [ParsedSaintText]
/// (REQ-F06-006). Tolerant of missing sections — only `name` has a
/// non-empty default ("Saint of the Day"), matching the reference
/// implementation exactly.
ParsedSaintText parseSaintText(String text) {
  final name = _extractSection(text, 'SAINT NAME');
  return ParsedSaintText(
    name: name.isEmpty ? 'Saint of the Day' : name,
    feast: _extractSection(text, 'FEAST DAY'),
    bornDied: _extractSection(text, 'BORN & DIED'),
    about: _extractSection(text, 'ABOUT'),
    saying: _extractSection(text, 'FAMOUS SAYING'),
    didYouKnow: _extractSection(text, 'DID YOU KNOW'),
    patronOf: _extractSection(text, 'PATRON OF'),
    prayer: _extractSection(text, 'PRAYER'),
  );
}
