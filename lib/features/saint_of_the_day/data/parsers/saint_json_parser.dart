import 'dart:convert';

import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/failures/saint_of_the_day_failure.dart';

final _dateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Parses a `GET /v1/saints/{date}` 200 body into a [SaintOfTheDay]
/// (REQ-F09-008).
///
/// Every one of the ten `Saint` fields is required and must be a string;
/// a missing or ill-typed field throws [SaintOfTheDayParsingFailure]
/// naming it. `dateKey` must be a real `YYYY-MM-DD` date, but is never
/// compared with the requested key (D-7). Unknown fields are ignored.
///
/// Content rules (empty name, no renderable sections) are applied by the
/// repository, not here, so this stays a pure shape check.
SaintOfTheDay parseSaintJson(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw SaintOfTheDayParsingFailure(
      'Response is not valid JSON: ${e.message}',
    );
  }
  if (decoded is! Map<String, dynamic>) {
    throw const SaintOfTheDayParsingFailure('Response is not a JSON object');
  }
  final Map<String, dynamic> json = decoded;

  String field(String key) {
    final value = json[key];
    if (value is String) return value;
    throw SaintOfTheDayParsingFailure(
      !json.containsKey(key)
          ? 'Field "$key" is missing'
          : 'Field "$key" is not a string',
    );
  }

  final dateKey = field('dateKey');
  if (!isWellFormedDateKey(dateKey)) {
    throw SaintOfTheDayParsingFailure(
      'Field "dateKey" is not a valid YYYY-MM-DD date: "$dateKey"',
    );
  }

  return SaintOfTheDay(
    name: field('name'),
    feast: field('feast'),
    bornDied: field('bornDied'),
    about: field('about'),
    saying: field('saying'),
    didYouKnow: field('didYouKnow'),
    patronOf: field('patronOf'),
    prayer: field('prayer'),
    dateKey: dateKey,
    displayDate: field('displayDate'),
  );
}

/// Whether [value] is `YYYY-MM-DD` and names a real calendar date (so
/// `2026-02-30` is rejected).
bool isWellFormedDateKey(String value) {
  if (!_dateKeyPattern.hasMatch(value)) return false;
  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(5, 7));
  final day = int.parse(value.substring(8, 10));
  final date = DateTime.utc(year, month, day);
  return date.year == year && date.month == month && date.day == day;
}
