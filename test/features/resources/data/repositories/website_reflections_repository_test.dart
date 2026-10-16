import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/resources/data/datasources/reflections_page_datasource.dart';
import 'package:st_luke_parish_app/features/resources/data/repositories/website_reflections_repository.dart';
import 'package:st_luke_parish_app/features/resources/domain/failures/reflections_failure.dart';

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

class _FakeDatasource extends ReflectionsPageDatasource {
  _FakeDatasource(this._result) : super(http.Client());

  final Future<String> Function() _result;

  @override
  Future<String> fetchPageHtml() => _result();
}

WebsiteReflectionsRepository _repository(String html, DateTime today) =>
    WebsiteReflectionsRepository(
      _FakeDatasource(() async => html),
      now: () => today,
    );

void main() {
  test("picks this month's booklet, wherever it sits on the page", () async {
    final reflection = await _repository(
      _page,
      DateTime(2026, 10, 16),
    ).getLatestReflection();

    expect(reflection.label, 'October 2026');
    expect(reflection.url, endsWith('/oct.pdf'));
  });

  test("falls back to the newest booklet out when this month's isn't up "
      'yet', () async {
    final reflection = await _repository(
      _page,
      DateTime(2026, 11, 2),
    ).getLatestReflection();

    expect(reflection.label, 'October 2026');
  });

  test('skips a booklet listed ahead of time for a later month', () async {
    final reflection = await _repository(
      _page,
      DateTime(2026, 9, 30),
    ).getLatestReflection();

    expect(reflection.label, 'September 2026');
  });

  test('if every booklet is for a later month, opens the earliest', () async {
    final reflection = await _repository(
      _page,
      DateTime(2025, 1, 1),
    ).getLatestReflection();

    expect(reflection.label, 'December 2025');
  });

  test('a page with no monthly links is a parsing failure', () {
    expect(
      _repository(
        '<a href="/p.pdf">The Five Pillars</a>',
        DateTime(2026, 10),
      ).getLatestReflection(),
      throwsA(isA<ReflectionsParsingFailure>()),
    );
  });

  test('links that are not web addresses are ignored', () {
    expect(
      _repository(
        '<a href="javascript:void(0)">October 2026</a>',
        DateTime(2026, 10),
      ).getLatestReflection(),
      throwsA(isA<ReflectionsParsingFailure>()),
    );
  });

  test('a network failure is passed on unchanged', () {
    final repository = WebsiteReflectionsRepository(
      _FakeDatasource(
        () async => throw const ReflectionsNetworkFailure('offline'),
      ),
    );
    expect(
      repository.getLatestReflection(),
      throwsA(isA<ReflectionsNetworkFailure>()),
    );
  });
}
