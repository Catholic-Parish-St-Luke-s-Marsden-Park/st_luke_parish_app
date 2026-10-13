import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/api_base_uri_provider.dart';
import '../../../../core/network/http_client_provider.dart';
import '../../data/cache/saint_of_the_day_cache.dart';
import '../../data/datasources/saint_of_the_day_remote_datasource.dart';
import '../../data/repositories/saint_of_the_day_repository_impl.dart';
import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/repositories/saint_of_the_day_repository.dart';

part 'saint_of_the_day_provider.g.dart';

/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract (REQ-F09-017): the parish API origin
/// comes from `apiBaseUriProvider` and the client from `httpClientProvider`,
/// as in `ministriesRepositoryProvider`. `Future`-typed because
/// `SharedPreferences.getInstance()` is itself async.
@riverpod
Future<SaintOfTheDayRepository> saintOfTheDayRepository(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SaintOfTheDayRepositoryImpl(
    SaintOfTheDayRemoteDatasource(
      ref.watch(httpClientProvider),
      baseUri: ref.watch(apiBaseUriProvider),
    ),
    SharedPreferencesSaintOfTheDayCache(prefs),
  );
}

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>`. `@riverpod` generates an `AutoDispose...`
/// provider by default; the on-device cache in `data/` (not this provider)
/// is what avoids requesting the same Sydney day from the parish API more
/// than once (REQ-F09-011).
@riverpod
Future<SaintOfTheDay> saintOfTheDay(Ref ref) async {
  final repository = await ref.watch(saintOfTheDayRepositoryProvider.future);
  return repository.getTodaysSaint();
}
