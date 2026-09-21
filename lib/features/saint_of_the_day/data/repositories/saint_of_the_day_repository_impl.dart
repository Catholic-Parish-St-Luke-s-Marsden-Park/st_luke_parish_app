import 'dart:developer' as developer;

import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/failures/saint_of_the_day_failure.dart';
import '../../domain/repositories/saint_of_the_day_repository.dart';
import '../cache/saint_of_the_day_cache.dart';
import '../datasources/openrouter_saint_datasource.dart';
import '../parsers/saint_text_parser.dart';
import '../sydney_date.dart';

/// The sole implementation of [SaintOfTheDayRepository]: orchestrates
/// cache-check -> (on miss) fetch -> parse -> cache-write, converting every
/// failure mode into a [SaintOfTheDayFailure] subtype rather than letting a
/// raw exception escape to the provider/UI.
class SaintOfTheDayRepositoryImpl implements SaintOfTheDayRepository {
  /// [clock] returns the current Sydney-local wall-clock time. It exists
  /// so tests can drive the day-rollover behaviour in REQ-F06-009
  /// directly; production call sites use the default. Without the seam a
  /// repository test can only assert against the real wall clock, which
  /// both fails to cover rollover and is itself flaky across Sydney
  /// midnight.
  SaintOfTheDayRepositoryImpl(
    this._datasource,
    this._cache, {
    DateTime Function() clock = sydneyNow,
  }) : _clock = clock;

  final OpenRouterSaintDatasource _datasource;
  final SaintOfTheDayCache _cache;
  final DateTime Function() _clock;

  @override
  Future<SaintOfTheDay> getTodaysSaint() async {
    final sydneyLocal = _clock();
    final dateKey = sydneyDateKey(sydneyLocal);

    // REQ-F06-008: cache hit -> no network call.
    final cached = await _cache.read(dateKey);
    if (cached != null) return cached;

    // REQ-F06-003 is enforced by the datasource itself, which owns the
    // API key and throws SaintOfTheDayNotConfiguredFailure before
    // issuing a request. That failure reaches the caller through the
    // `on SaintOfTheDayFailure { rethrow; }` below. A second copy of the
    // check (and of its message) used to live here and shadowed the
    // datasource's, making that branch unreachable outside its own unit
    // test and giving the RISK-008 follow-up two places to edit.

    final String rawText;
    try {
      rawText = await _datasource.fetchSaintText(
        sydneyFullDateForPrompt(sydneyLocal),
      );
    } on SaintOfTheDayFailure {
      rethrow;
    } catch (e) {
      // Defensive fallback (CLAUDE.md: "do not swallow exceptions
      // silently") — any unexpected error while fetching is still
      // surfaced as a typed, user-safe failure.
      throw SaintOfTheDayNetworkFailure('Unexpected error fetching: $e');
    }

    final ParsedSaintText parsed;
    try {
      parsed = parseSaintText(rawText);
    } catch (e) {
      throw SaintOfTheDayParsingFailure(
        'Unexpected error parsing the model response: $e',
      );
    }

    // A 200 response carrying no recognisable `**LABEL:**` sections — a
    // refusal ("I'm sorry, I can't help with that"), a truncated
    // generation, or plain prose — parses tolerantly into the default
    // name and eight empty strings. Left unchecked, that renders as an
    // `AsyncData` success: header only, zero section cards, no error view
    // and no "Try again" button. Caching it would then pin the user to
    // that blank page for the rest of the Sydney day. Treat it as a
    // parsing failure so the retry-capable error view is shown instead,
    // and so nothing is written to the cache.
    if (!_hasRenderableContent(parsed)) {
      throw const SaintOfTheDayParsingFailure(
        'The model response contained no recognisable saint sections.',
      );
    }

    final result = SaintOfTheDay(
      name: parsed.name,
      feast: parsed.feast,
      bornDied: parsed.bornDied,
      about: parsed.about,
      saying: parsed.saying,
      didYouKnow: parsed.didYouKnow,
      patronOf: parsed.patronOf,
      prayer: parsed.prayer,
      dateKey: dateKey,
      displayDate: sydneyDisplayDate(sydneyLocal),
    );

    // REQ-F06-009: write-through; a new date key naturally supersedes
    // yesterday's entry since `read` only matches on an exact date-key hit.
    //
    // Caching is best-effort and must not be able to fail the read: the
    // content has already been fetched and paid for. Unguarded, a
    // shared_preferences platform-channel failure (disk full, channel
    // error while backgrounding) would discard a good result, show the
    // generic "something went wrong" view, and escape as a
    // non-SaintOfTheDayFailure — breaking the contract stated in
    // `domain/repositories/saint_of_the_day_repository.dart`.
    try {
      await _cache.write(dateKey, result);
    } catch (e) {
      // Logged, not silent (CLAUDE.md), but deliberately not rethrown:
      // the user still gets today's saint, they just pay for another
      // fetch next time the screen is opened. No key or response body is
      // included.
      developer.log(
        'Failed to cache the saint for $dateKey: $e',
        name: 'SaintOfTheDayRepository',
      );
    }

    return result;
  }

  /// Whether [parsed] carries at least one section the screen can
  /// actually render. `name` is deliberately excluded: it falls back to
  /// "Saint of the Day" when absent (REQ-F06-006), so it is never empty
  /// and cannot distinguish a good parse from a failed one. `feast` is
  /// excluded for the same practical reason — on its own it yields a
  /// header pill and no content.
  bool _hasRenderableContent(ParsedSaintText parsed) =>
      parsed.about.isNotEmpty ||
      parsed.bornDied.isNotEmpty ||
      parsed.saying.isNotEmpty ||
      parsed.didYouKnow.isNotEmpty ||
      parsed.patronOf.isNotEmpty ||
      parsed.prayer.isNotEmpty;
}
