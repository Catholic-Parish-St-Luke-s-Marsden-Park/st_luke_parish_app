import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/cache/saint_of_the_day_cache.dart';
import '../../data/datasources/openrouter_saint_datasource.dart';
import '../../data/repositories/saint_of_the_day_repository_impl.dart';
import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/repositories/saint_of_the_day_repository.dart';

part 'saint_of_the_day_provider.g.dart';

/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract, so a future Supabase-backed cache
/// (see ADR-0005) can be swapped in later without touching presentation
/// code — same pattern as `bulletinsRepositoryProvider`. `Future`-typed
/// because `SharedPreferences.getInstance()` is itself async.
@riverpod
Future<SaintOfTheDayRepository> saintOfTheDayRepository(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SaintOfTheDayRepositoryImpl(
    OpenRouterSaintDatasource(ref.watch(httpClientProvider)),
    SharedPreferencesSaintOfTheDayCache(prefs),
  );
}

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>` (REQ-F06-011). `@riverpod` generates an
/// `AutoDispose...` provider by default; the on-device cache in `data/`
/// (not this provider) is what avoids re-calling OpenRouter more than once
/// per Sydney calendar day (REQ-F06-008).
@riverpod
Future<SaintOfTheDay> saintOfTheDay(Ref ref) async {
  final repository = await ref.watch(saintOfTheDayRepositoryProvider.future);
  return repository.getTodaysSaint();
}
