import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/api_base_uri_provider.dart';
import '../../../../core/network/http_client_provider.dart';
import '../../data/cache/ministries_cache.dart';
import '../../data/datasources/bundled_ministries_source.dart';
import '../../data/datasources/ministries_remote_datasource.dart';
import '../../data/repositories/ministries_repository_impl.dart';
import '../../domain/entities/ministry.dart';
import '../../domain/entities/ministry_category.dart';
import '../../domain/failures/ministries_failure.dart';
import '../../domain/repositories/ministries_repository.dart';

part 'ministries_providers.g.dart';

/// Wires [MinistriesRepositoryImpl] behind the [MinistriesRepository]
/// contract. `Future`-typed because `SharedPreferences.getInstance()` is
/// async, as in `saintOfTheDayRepositoryProvider`.
@riverpod
Future<MinistriesRepository> ministriesRepository(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return MinistriesRepositoryImpl(
    MinistriesRemoteDatasource(
      ref.watch(httpClientProvider),
      baseUri: ref.watch(apiBaseUriProvider),
    ),
    SharedPreferencesMinistriesCache(prefs),
    BundledMinistriesSource(rootBundle),
  );
}

/// Ministries grouped by category, in API order. Emits the saved copy first
/// and the fresh one when it arrives (see
/// [MinistriesRepository.watchMinistries]).
@riverpod
class Ministries extends _$Ministries {
  @override
  Stream<List<MinistryCategory>> build() async* {
    final repository = await ref.watch(ministriesRepositoryProvider.future);
    yield* repository.watchMinistries();
  }

  /// Pull-to-refresh. Replaces the list on success. On failure keeps the
  /// current list and returns false so the screen can say so.
  Future<bool> refresh() async {
    try {
      final repository = await ref.read(ministriesRepositoryProvider.future);
      final fresh = await repository.refreshMinistries();
      if (!ref.mounted) return false;
      state = AsyncData(fresh);
      return true;
    } on MinistriesFailure catch (e) {
      developer.log('Pull-to-refresh failed: $e', name: 'MinistriesProvider');
      return false;
    }
  }
}

/// A single ministry for the detail screen: taken from the loaded list when
/// it's there, otherwise fetched by id (e.g. a future deep link). Throws
/// [MinistryNotFoundFailure] for an unknown or hidden id.
@riverpod
Future<Ministry> ministryById(Ref ref, String id) async {
  final categories = await ref.watch(ministriesProvider.future);
  for (final category in categories) {
    for (final ministry in category.ministries) {
      if (ministry.id == id) return ministry;
    }
  }
  final repository = await ref.watch(ministriesRepositoryProvider.future);
  return repository.getMinistryById(id);
}
