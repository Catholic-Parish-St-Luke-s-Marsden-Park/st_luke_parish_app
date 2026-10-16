import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:st_luke_parish_app/features/parish/data/datasources/parish_home_page_datasource.dart';
import 'package:st_luke_parish_app/features/parish/data/repositories/website_parish_notice_repository.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';

const _popupPage = '''
<div class="fl-module fl-module-modal-popup fl-node-6943274a9606b">
  <div class="uabb-modal-text uabb-modal-content-data">
    <img decoding="async" alt=""
      data-src="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/STD-LS-SLMP-1024x724.jpg"
      class="lazyload"
      src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" />
    <noscript><img src="https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/STD-LS-SLMP-1024x724.jpg" alt=""/></noscript>
  </div>
</div>
<img src="https://stlukesmarsdenpark.org.au/logo.png" alt="Not the pop-up">
''';

const _poster =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
    'STD-LS-SLMP-1024x724.jpg';

class _FakeDatasource extends ParishHomePageDatasource {
  _FakeDatasource(this._result, {this.imageAvailable = true})
    : super(http.Client());

  final Future<String> Function() _result;
  final bool imageAvailable;

  @override
  Future<String> fetchHomePageHtml() => _result();

  @override
  Future<bool> isImageAvailable(String url) async => imageAvailable;
}

void main() {
  test("returns the home page's pop-up image as the notice", () async {
    final notice = await WebsiteParishNoticeRepository(
      _FakeDatasource(() async => _popupPage),
    ).getCurrentNotice();
    expect(notice?.imageUrl, _poster);
  });

  test('returns null when the pop-up image no longer loads', () async {
    final notice = await WebsiteParishNoticeRepository(
      _FakeDatasource(() async => _popupPage, imageAvailable: false),
    ).getCurrentNotice();
    expect(notice, isNull);
  });

  test('returns null when the home page has no pop-up', () async {
    final notice = await WebsiteParishNoticeRepository(
      _FakeDatasource(() async => '<h1>Welcome</h1>'),
    ).getCurrentNotice();
    expect(notice, isNull);
  });

  test('a network failure is passed on unchanged', () {
    expect(
      WebsiteParishNoticeRepository(
        _FakeDatasource(
          () async => throw const ParishDocumentsNetworkFailure('offline'),
        ),
      ).getCurrentNotice(),
      throwsA(isA<ParishDocumentsNetworkFailure>()),
    );
  });
}
