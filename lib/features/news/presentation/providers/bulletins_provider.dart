import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/datasources/bulletins_feed_datasource.dart';
import '../../data/repositories/feed_bulletins_repository.dart';
import '../../domain/entities/bulletin.dart';
import '../../domain/repositories/bulletins_repository.dart';

part 'bulletins_provider.g.dart';

/// Wires the concrete [FeedBulletinsRepository] behind the abstract
/// [BulletinsRepository] contract, so a future scraped/remote data source
/// can be swapped in later without touching presentation code (same pattern
/// as `massScheduleProvider`).
@riverpod
BulletinsRepository bulletinsRepository(Ref ref) {
  return FeedBulletinsRepository(
    BulletinsFeedDatasource(ref.watch(httpClientProvider)),
  );
}

/// Exposes bulletins to [NewsScreen] as `AsyncValue<List<Bulletin>>`
/// (REQ-F05-014). `@riverpod` generates an `AutoDispose...` provider by
/// default — no caching across screen entries, matching REQ-F05-014's
/// "no cross-screen-entry caching" requirement and CLAUDE.md's "no local
/// persistence until there's a clear requirement" rule.
@riverpod
Future<List<Bulletin>> bulletins(Ref ref) {
  return ref.watch(bulletinsRepositoryProvider).getBulletins();
}
