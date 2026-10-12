import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/parsers/saint_json_parser.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';

import '../saint_json_fixtures.dart';

/// REQ-F09-008 and REQ-F09-010.
void main() {
  const fields = [
    'name',
    'feast',
    'bornDied',
    'about',
    'saying',
    'didYouKnow',
    'patronOf',
    'prayer',
    'dateKey',
    'displayDate',
  ];

  Matcher parsingFailureMentioning(String text) => throwsA(
    isA<SaintOfTheDayParsingFailure>().having(
      (f) => f.message,
      'message',
      contains(text),
    ),
  );

  test('parses a valid payload, keeping an empty saying', () {
    final saint = parseSaintJson(saintJson());

    expect(saint.name, 'Saint Wilfrid, Bishop');
    expect(saint.feast, 'October 12 - Optional Memorial');
    expect(saint.bornDied, 'c. 633, Northumbria - 709, Oundle');
    expect(saint.about, startsWith('A bishop of York'));
    expect(saint.saying, isEmpty);
    expect(saint.didYouKnow, 'He evangelised the South Saxons.');
    expect(saint.patronOf, 'Middlesbrough');
    expect(saint.prayer, 'Saint Wilfrid, pray for us.');
    expect(saint.dateKey, '2026-10-12');
    expect(saint.displayDate, 'October 12');
  });

  test('ignores unknown fields', () {
    final saint = parseSaintJson(
      saintJson(overrides: {'source': 'martyrology', 'version': 2}),
    );

    expect(saint.name, 'Saint Wilfrid, Bishop');
  });

  test('accepts a dateKey that differs from today (D-7)', () {
    final saint = parseSaintJson(saintJson(dateKey: '2026-10-13'));

    expect(saint.dateKey, '2026-10-13');
  });

  for (final field in fields) {
    test('a missing "$field" is a parsing failure naming it', () {
      expect(
        () => parseSaintJson(saintJson(without: [field])),
        parsingFailureMentioning('"$field" is missing'),
      );
    });

    test('a non-string "$field" is a parsing failure naming it', () {
      expect(
        () => parseSaintJson(saintJson(overrides: {field: 42})),
        parsingFailureMentioning('"$field" is not a string'),
      );
    });
  }

  test('a null field is reported as not a string', () {
    expect(
      () => parseSaintJson(saintJson(overrides: {'prayer': null})),
      parsingFailureMentioning('"prayer" is not a string'),
    );
  });

  for (final bad in [
    '12-10-2026',
    '2026-1-12',
    '2026-10-12T00:00:00Z',
    '2026-02-30',
    '2026-13-01',
    '',
  ]) {
    test('a malformed dateKey "$bad" is a parsing failure', () {
      expect(
        () => parseSaintJson(saintJson(dateKey: bad)),
        parsingFailureMentioning('dateKey'),
      );
    });
  }

  test('malformed JSON is a parsing failure', () {
    expect(
      () => parseSaintJson('{"name": "Saint'),
      parsingFailureMentioning('not valid JSON'),
    );
  });

  test('a JSON array is a parsing failure', () {
    expect(
      () => parseSaintJson('[]'),
      parsingFailureMentioning('not a JSON object'),
    );
  });

  group('isWellFormedDateKey', () {
    test('accepts real dates, including a leap day', () {
      expect(isWellFormedDateKey('2026-10-12'), isTrue);
      expect(isWellFormedDateKey('2028-02-29'), isTrue);
    });

    test('rejects impossible dates', () {
      expect(isWellFormedDateKey('2026-02-29'), isFalse);
      expect(isWellFormedDateKey('2026-00-10'), isFalse);
    });
  });
}
