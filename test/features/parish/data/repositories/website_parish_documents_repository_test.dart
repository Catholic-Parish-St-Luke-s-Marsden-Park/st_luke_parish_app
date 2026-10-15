import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_documents_repository.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';

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

class _FakeDatasource extends ParishHomePageDatasource {
  _FakeDatasource(this._result) : super(http.Client());

  final Future<String> Function() _result;

  @override
  Future<String> fetchHomePageHtml() => _result();
}

WebsiteParishDocumentsRepository _repositoryReturning(String html) =>
    WebsiteParishDocumentsRepository(_FakeDatasource(() async => html));

void main() {
  test('returns the latest minutes link from the home page', () async {
    expect(
      await _repositoryReturning(_homePage).getLatestCouncilMinutesUrl(),
      _latestMinutes,
    );
  });

  test('a home page without the minutes button is a parsing failure', () {
    expect(
      _repositoryReturning(
        '<a href="/plan.pdf">Parish Pastoral Plan</a>',
      ).getLatestCouncilMinutesUrl(),
      throwsA(isA<ParishDocumentsParsingFailure>()),
    );
  });

  test('a link that is not a web address is a parsing failure', () {
    expect(
      _repositoryReturning(
        '<a href="javascript:void(0)">Pastoral Council Minutes</a>',
      ).getLatestCouncilMinutesUrl(),
      throwsA(isA<ParishDocumentsParsingFailure>()),
    );
  });

  test('a network failure is passed on unchanged', () {
    final repository = WebsiteParishDocumentsRepository(
      _FakeDatasource(
        () async => throw const ParishDocumentsNetworkFailure('offline'),
      ),
    );
    expect(
      repository.getLatestCouncilMinutesUrl(),
      throwsA(isA<ParishDocumentsNetworkFailure>()),
    );
  });
}
