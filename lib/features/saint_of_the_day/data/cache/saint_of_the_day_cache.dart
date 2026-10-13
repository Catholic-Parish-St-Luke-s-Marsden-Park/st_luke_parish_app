import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saint_of_the_day.dart';

/// Cache boundary for today's saint (REQ-F06-010, kept by D-2 of feature
/// 09). Deliberately narrow (read/write by date key only), so it saves a
/// request to the parish API per Sydney day without the repository, the
/// domain entity or the presentation layer depending on how it is stored
/// — see ADR-0008.
abstract class SaintOfTheDayCache {
  /// Returns the cached entry for [dateKey] (`YYYY-MM-DD`, Sydney-local),
  /// or `null` on a cache miss.
  Future<SaintOfTheDay?> read(String dateKey);

  /// Stores [value] under [dateKey], replacing any previously-cached entry
  /// for a different date (REQ-F06-009) — this cache only ever holds the
  /// current day's entry, mirroring the reference Netlify function's
  /// server-side cache behaviour.
  Future<void> write(String dateKey, SaintOfTheDay value);
}

/// On-device implementation of [SaintOfTheDayCache] using
/// `shared_preferences` (REQ-F06-010) — an interim measure while
/// Supabase/Firebase is not yet set up in this project (per the approved
/// BA plan). Per-install only, not shared across users/devices.
class SharedPreferencesSaintOfTheDayCache implements SaintOfTheDayCache {
  SharedPreferencesSaintOfTheDayCache(this._prefs);

  final SharedPreferences _prefs;

  static const _dateKeyKey = 'saint_of_the_day_cache_date_key';
  static const _valueKey = 'saint_of_the_day_cache_value';

  @override
  Future<SaintOfTheDay?> read(String dateKey) async {
    final cachedDateKey = _prefs.getString(_dateKeyKey);
    if (cachedDateKey != dateKey) return null;

    final raw = _prefs.getString(_valueKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      // Second line of defence behind `write`'s commit-last ordering: the
      // stored entry carries its own date key, so an entry that does not
      // belong to the requested date is a miss even if the standalone
      // key field says otherwise.
      if (json['dateKey'] != dateKey) return null;
      return SaintOfTheDay(
        name: json['name'] as String,
        feast: json['feast'] as String,
        bornDied: json['bornDied'] as String,
        about: json['about'] as String,
        saying: json['saying'] as String,
        didYouKnow: json['didYouKnow'] as String,
        patronOf: json['patronOf'] as String,
        prayer: json['prayer'] as String,
        dateKey: json['dateKey'] as String,
        displayDate: json['displayDate'] as String,
      );
    } catch (_) {
      // A corrupted/old-shape cache entry is treated as a miss, not a
      // crash — the repository will simply re-fetch (REQ-F06-007's
      // "defensive, don't crash" principle applied to the cache path too).
      return null;
    }
  }

  @override
  Future<void> write(String dateKey, SaintOfTheDay value) async {
    // Commit-last ordering. The date key is the field `read` matches on,
    // so it is written *after* the value it points at, never before: if
    // the process is killed (backgrounded, OOM) or the second write fails
    // partway through, the still-stale key simply fails to match and the
    // next read is a clean miss that re-fetches. Writing the key first
    // would instead leave today's key pointing at yesterday's entry,
    // which decodes successfully and renders as a silent `AsyncData`
    // success — yesterday's saint, with yesterday's date in the header,
    // for the rest of the day and with no retry path out of it.
    final wroteValue = await _prefs.setString(
      _valueKey,
      jsonEncode({
        'name': value.name,
        'feast': value.feast,
        'bornDied': value.bornDied,
        'about': value.about,
        'saying': value.saying,
        'didYouKnow': value.didYouKnow,
        'patronOf': value.patronOf,
        'prayer': value.prayer,
        'dateKey': value.dateKey,
        'displayDate': value.displayDate,
      }),
    );
    // A failed value write leaves the cache untouched rather than
    // half-committed — the next read misses and re-fetches.
    if (!wroteValue) return;

    await _prefs.setString(_dateKeyKey, dateKey);
  }
}
