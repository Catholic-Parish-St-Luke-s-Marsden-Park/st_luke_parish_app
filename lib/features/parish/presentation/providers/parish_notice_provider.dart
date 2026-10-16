import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/datasources/parish_home_page_datasource.dart';
import '../../data/repositories/website_parish_notice_repository.dart';
import '../../domain/entities/parish_notice.dart';
import '../../domain/repositories/parish_notice_repository.dart';

part 'parish_notice_provider.g.dart';

/// Wires the website-backed repository behind the abstract contract.
@riverpod
ParishNoticeRepository parishNoticeRepository(Ref ref) {
  return WebsiteParishNoticeRepository(
    ParishHomePageDatasource(ref.watch(httpClientProvider)),
  );
}

/// The home page's current pop-up notice (`null` when there is none),
/// read when the app opens; the floating announcement button shows only
/// while there is one.
@riverpod
Future<ParishNotice?> currentParishNotice(Ref ref) {
  return ref.watch(parishNoticeRepositoryProvider).getCurrentNotice();
}
