import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/datasources/reflections_page_datasource.dart';
import '../../data/repositories/website_reflections_repository.dart';
import '../../domain/entities/monthly_reflection.dart';
import '../../domain/repositories/reflections_repository.dart';

part 'reflections_provider.g.dart';

/// Wires the website-backed repository behind the abstract contract.
@riverpod
ReflectionsRepository reflectionsRepository(Ref ref) {
  return WebsiteReflectionsRepository(
    ReflectionsPageDatasource(ref.watch(httpClientProvider)),
  );
}

/// The current Daily Readings & Reflections booklet. Auto-disposed, so it
/// is read afresh each time the Resources page opens.
@riverpod
Future<MonthlyReflection> latestReflection(Ref ref) {
  return ref.watch(reflectionsRepositoryProvider).getLatestReflection();
}
