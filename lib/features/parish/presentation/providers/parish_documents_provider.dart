import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/datasources/parish_home_page_datasource.dart';
import '../../data/repositories/website_parish_documents_repository.dart';
import '../../domain/repositories/parish_documents_repository.dart';

part 'parish_documents_provider.g.dart';

/// Wires the website-backed repository behind the abstract contract.
@riverpod
ParishDocumentsRepository parishDocumentsRepository(Ref ref) {
  return WebsiteParishDocumentsRepository(
    ParishHomePageDatasource(ref.watch(httpClientProvider)),
  );
}

/// The latest Pastoral Council minutes URL from the parish home page.
/// Auto-disposed, so it is read afresh each time the Pastoral Plan is
/// opened.
@riverpod
Future<String> latestCouncilMinutesUrl(Ref ref) {
  return ref
      .watch(parishDocumentsRepositoryProvider)
      .getLatestCouncilMinutesUrl();
}
