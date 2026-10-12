import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/data/parsers/problem_details_parser.dart';

import '../saint_json_fixtures.dart';

/// REQ-F09-005: problem bodies are read tolerantly and never throw.
void main() {
  test('reads status, code, title and requestId', () {
    final problem = parseProblemDetails(
      problemJson(status: 503, code: 'saint_not_ready', requestId: 'abc-123'),
    );

    expect(problem, isNotNull);
    expect(problem!.status, 503);
    expect(problem.code, 'saint_not_ready');
    expect(problem.title, 'Problem saint_not_ready');
    expect(problem.requestId, 'abc-123');
  });

  test('a body without requestId leaves it null', () {
    final problem = parseProblemDetails(
      problemJson(status: 404, code: 'saint_not_available'),
    );

    expect(problem!.code, 'saint_not_available');
    expect(problem.requestId, isNull);
  });

  test('ill-typed members are left out', () {
    final problem = parseProblemDetails(
      '{"status": "503", "code": 7, "requestId": ""}',
    );

    expect(problem, isNotNull);
    expect(problem!.status, isNull);
    expect(problem.code, isNull);
    expect(problem.requestId, isNull);
  });

  for (final body in [
    '',
    '   ',
    'Service Unavailable',
    '<html></html>',
    '[]',
  ]) {
    test('a non-problem body "$body" yields null', () {
      expect(parseProblemDetails(body), isNull);
    });
  }
}
