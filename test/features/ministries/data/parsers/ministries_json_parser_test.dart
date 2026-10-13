import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ministries/data/parsers/ministries_json_parser.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';

import '../ministries_json_fixtures.dart';

/// REQ-F08-003 (typed parsing failures, unknown fields ignored) and
/// REQ-F08-004 (API order kept).
void main() {
  Matcher parsingFailure(String messageFragment) => throwsA(
    isA<MinistriesParsingFailure>().having(
      (f) => f.message,
      'message',
      contains(messageFragment),
    ),
  );

  group('parseMinistriesJson', () {
    test('parses categories and ministries in API order', () {
      final categories = parseMinistriesJson(ministriesBody());

      expect(categories.map((c) => c.name), ['Cat A', 'Cat B']);
      expect(categories[0].ministries.map((m) => m.id), ['a1', 'a2']);
      expect(categories[1].ministries.map((m) => m.id), ['b1']);

      final a1 = categories[0].ministries[0];
      expect(a1.category, 'Cat A');
      expect(a1.name, 'Name a1');
      expect(a1.membersLine, 'Members a1');
      expect(a1.dayLine, 'Day a1');
      expect(a1.tagline, 'Tagline a1');
      expect(a1.time, 'Sat 5:30pm · Sun 8am');
      expect(a1.location, 'Location a1');
      expect(a1.open, 'Open a1');
      expect(a1.about, 'About a1\n\nSecond paragraph — a1');
      expect(a1.leaderName, 'Leader a1');
      expect(a1.leaderRole, 'Role a1');
      expect(a1.leaderInitials, 'LI');
      expect(a1.joinInfo, 'Join a1');
      expect(a1.ctaLabel, 'Join a1');
      expect(a1.contactEmail, 'office@example.org');
      expect(a1.emailSubject, 'a1 Interest');
    });

    test('an empty items list parses to no categories', () {
      expect(parseMinistriesJson('{"items": []}'), isEmpty);
    });

    test('accepts an empty emailSubject', () {
      final json = ministryJson('a1')..['emailSubject'] = '';
      final body = jsonEncode({
        'items': [
          {
            'name': 'Cat A',
            'ministries': [json],
          },
        ],
      });

      expect(
        parseMinistriesJson(body).single.ministries.single.emailSubject,
        '',
      );
    });

    test('ignores unknown fields at every level', () {
      final json = ministryJson('a1')..['photoUrl'] = 'https://x/y.png';
      final body = jsonEncode({
        'items': [
          {
            'name': 'Cat A',
            'ministries': [json],
            'sortOrder': 1,
          },
        ],
        'generatedAt': '2026-10-08T00:00:00Z',
      });

      expect(parseMinistriesJson(body).single.ministries.single.id, 'a1');
    });

    test('a missing ministry field throws, naming its path', () {
      final json = ministryJson('a1')..remove('contactEmail');
      final body = jsonEncode({
        'items': [
          {
            'name': 'Cat A',
            'ministries': [ministryJson('a0'), json],
          },
        ],
      });

      expect(
        () => parseMinistriesJson(body),
        parsingFailure('items[0].ministries[1].contactEmail is missing'),
      );
    });

    test('an ill-typed ministry field throws, naming its path', () {
      final json = ministryJson('a1')..['name'] = 42;
      final body = jsonEncode({
        'items': [
          {
            'name': 'Cat A',
            'ministries': [json],
          },
        ],
      });

      expect(
        () => parseMinistriesJson(body),
        parsingFailure('items[0].ministries[0].name is not a String'),
      );
    });

    test('an empty id throws', () {
      final json = ministryJson('a1')..['id'] = ' ';
      final body = jsonEncode({
        'items': [
          {
            'name': 'Cat A',
            'ministries': [json],
          },
        ],
      });

      expect(() => parseMinistriesJson(body), parsingFailure('id is empty'));
    });

    test('a missing items envelope throws', () {
      expect(() => parseMinistriesJson('{}'), parsingFailure(r'$.items'));
    });

    test('a category without a ministries list throws', () {
      expect(
        () => parseMinistriesJson('{"items": [{"name": "Cat A"}]}'),
        parsingFailure('items[0].ministries is missing'),
      );
    });

    test('a non-object root throws', () {
      expect(
        () => parseMinistriesJson('[]'),
        parsingFailure('is not a JSON object'),
      );
    });

    test('malformed JSON throws', () {
      expect(
        () => parseMinistriesJson('{"items": ['),
        parsingFailure('not valid JSON'),
      );
    });
  });

  group('parseMinistryJson', () {
    test('parses a single ministry', () {
      final ministry = parseMinistryJson(jsonEncode(ministryJson('solo')));

      expect(ministry.id, 'solo');
      expect(ministry.name, 'Name solo');
    });

    test('a missing field throws', () {
      final json = ministryJson('solo')..remove('ctaLabel');

      expect(
        () => parseMinistryJson(jsonEncode(json)),
        parsingFailure(r'$.ctaLabel is missing'),
      );
    });
  });
}
