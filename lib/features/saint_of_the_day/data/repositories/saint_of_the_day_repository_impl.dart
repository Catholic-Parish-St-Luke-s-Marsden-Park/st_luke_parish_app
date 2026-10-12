import 'dart:developer' as developer;

import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/failures/saint_of_the_day_failure.dart';
import '../../domain/repositories/saint_of_the_day_repository.dart';
import '../cache/saint_of_the_day_cache.dart';
import '../datasources/saint_of_the_day_remote_datasource.dart';
import '../parsers/saint_json_parser.dart';
import '../sydney_date.dart';

/// The sole implementation of [SaintOfTheDayRepository]: orchestrates
/// date key -> cache check -> (on miss) `GET /v1/saints/{dateKey}` ->
/// parse -> content guard -> best-effort cache write, converting every
/// failure into a [SaintOfTheDayFailure] subtype rather than letting a raw
/// exception escape to the provider/UI.
class SaintOfTheDayRepositoryImpl implements SaintOfTheDayRepository {
  /// [clock] returns the current Sydney-local wall-clock time. It exists
  /// so tests can drive day rollover directly; production call sites use
  /// the default.
  SaintOfTheDayRepositoryImpl(
    this._datasource,
    this._cache, {
    DateTime Function() clock = sydneyNow,
  }) : _clock = clock;

  final SaintOfTheDayRemoteDatasource _datasource;
  final SaintOfTheDayCache _cache;
  final DateTime Function() _clock;

  @override
  Future<SaintOfTheDay> getTodaysSaint() async {
    // Computed once and used for both the cache lookup and the request
    // (D-3, REQ-F09-001, REQ-F09-011).
    final dateKey = sydneyDateKey(_clock());

    final cached = await _cache.read(dateKey);
    if (cached != null) return cached;

    try {
      final saint = await _fetchAndValidate(dateKey);
      await _writeBestEffort(saint);
      return saint;
    } on SaintOfTheDayFailure catch (failure) {
      // One log line per failure, carrying the dateKey, HTTP status,
      // problem code and requestId the failure's message holds
      // (REQ-F09-007). The cache is not touched (REQ-F09-014).
      developer.log(
        'Saint of the Day failed: $failure',
        name: 'SaintOfTheDayRepository',
      );
      rethrow;
    }
  }

  Future<SaintOfTheDay> _fetchAndValidate(String dateKey) async {
    final String body;
    try {
      body = await _datasource.fetchSaintJson(dateKey);
    } on SaintOfTheDayFailure {
      rethrow;
    } catch (e) {
      // Defensive fallback (CLAUDE.md: "do not swallow exceptions
      // silently"): the datasource already maps everything it expects.
      throw SaintOfTheDayNetworkFailure(
        'Unexpected error fetching dateKey=$dateKey: $e',
      );
    }

    final SaintOfTheDay saint;
    try {
      saint = parseSaintJson(body);
    } on SaintOfTheDayParsingFailure catch (e) {
      throw SaintOfTheDayParsingFailure('dateKey=$dateKey: ${e.message}');
    } catch (e) {
      throw SaintOfTheDayParsingFailure(
        'dateKey=$dateKey: unexpected error parsing the response: $e',
      );
    }

    // D-6 / REQ-F09-009: a 200 that would render as a blank page is a
    // retryable parsing failure, and is never cached.
    if (saint.name.trim().isEmpty) {
      throw SaintOfTheDayParsingFailure(
        'dateKey=$dateKey: the response has an empty name.',
      );
    }
    if (!_hasRenderableContent(saint)) {
      throw SaintOfTheDayParsingFailure(
        'dateKey=$dateKey: the response has no non-empty content sections.',
      );
    }
    return saint;
  }

  /// REQ-F09-012: stored under the server's `dateKey` (D-7). Caching is
  /// best-effort and must not fail a read that already succeeded: a
  /// shared_preferences failure is logged, not rethrown, and the user
  /// simply pays for another request next time.
  Future<void> _writeBestEffort(SaintOfTheDay saint) async {
    try {
      await _cache.write(saint.dateKey, saint);
    } catch (e) {
      developer.log(
        'Failed to cache the saint for ${saint.dateKey}: $e',
        name: 'SaintOfTheDayRepository',
      );
    }
  }

  /// Whether [saint] has at least one section card the screen can render.
  /// `name` and `feast` alone yield a header and nothing else.
  bool _hasRenderableContent(SaintOfTheDay saint) => [
    saint.about,
    saint.bornDied,
    saint.saying,
    saint.didYouKnow,
    saint.patronOf,
    saint.prayer,
  ].any((section) => section.trim().isNotEmpty);
}
