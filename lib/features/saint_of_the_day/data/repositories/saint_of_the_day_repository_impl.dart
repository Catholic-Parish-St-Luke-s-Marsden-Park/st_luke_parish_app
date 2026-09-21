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
  SaintOfTheDayRepositoryImpl(this._datasource, this._cache);

  final OpenRouterSaintDatasource _datasource;
  final SaintOfTheDayCache _cache;

  @override
  Future<SaintOfTheDay> getTodaysSaint() async {
    final sydneyLocal = sydneyNow();
    final dateKey = sydneyDateKey(sydneyLocal);

    // REQ-F06-008: cache hit -> no network call.
    final cached = await _cache.read(dateKey);
    if (cached != null) return cached;

    // REQ-F06-003: surfaced as a typed failure before any request is sent.
    if (!_datasource.isConfigured) {
      throw const SaintOfTheDayNotConfiguredFailure(
        'OPENROUTER_API_KEY was not supplied at build/run time.',
      );
    }

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
    await _cache.write(dateKey, result);

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
