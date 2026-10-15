import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_documents_repository.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';

const _plan =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
    'Parish-Pastoral-Plan-2026-2028.pdf';
const _minutes =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/10/'
    '17-October-2026-Parish-Pastoral-Council-Meeting-Minutes.pdf';

const _planButton =
    '<a href="$_plan"><span>Parish Pastoral Plan 2026-2028</span></a>';
const _minutesButton =
    '<a href="$_minutes"><span>Parish Pastoral Council Meeting Minutes'
    '</span></a>';

class _FakeDatasource extends ParishHomePageDatasource {
  _FakeDatasource(this._result) : super(http.Client());

  final Future<String> Function() _result;

  @override
  Future<String> fetchHomePageHtml() => _result();
}

WebsiteParishDocumentsRepository _repositoryReturning(String html) =>
    WebsiteParishDocumentsRepository(_FakeDatasource(() async => html));

void main() {
  test('returns both links from one read of the home page', () async {
    var fetches = 0;
    final repository = WebsiteParishDocumentsRepository(
      _FakeDatasource(() async {
        fetches++;
        return '$_planButton$_minutesButton';
      }),
    );

    final links = await repository.getDocumentLinks();

    expect(links.pastoralPlanUrl, _plan);
    expect(links.councilMinutesUrl, _minutes);
    expect(fetches, 1);
  });

  test('a missing button leaves just that link empty', () async {
    final onlyMinutes = await _repositoryReturning(
      _minutesButton,
    ).getDocumentLinks();
    expect(onlyMinutes.pastoralPlanUrl, isNull);
    expect(onlyMinutes.councilMinutesUrl, _minutes);

    final onlyPlan = await _repositoryReturning(_planButton).getDocumentLinks();
    expect(onlyPlan.pastoralPlanUrl, _plan);
    expect(onlyPlan.councilMinutesUrl, isNull);
  });

  test('a link that is not a web address is left empty', () async {
    final links = await _repositoryReturning(
      '$_planButton<a href="javascript:void(0)">Pastoral Council Minutes</a>',
    ).getDocumentLinks();
    expect(links.pastoralPlanUrl, _plan);
    expect(links.councilMinutesUrl, isNull);
  });

  test('a home page with neither button is a parsing failure', () {
    expect(
      _repositoryReturning('<a href="/donate/">Donate</a>').getDocumentLinks(),
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
      repository.getDocumentLinks(),
      throwsA(isA<ParishDocumentsNetworkFailure>()),
    );
  });
}
