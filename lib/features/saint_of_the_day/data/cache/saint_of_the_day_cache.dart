import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saint_of_the_day.dart';

/// Cache boundary for today's saint (REQ-F06-010). Deliberately narrow
/// (read/write by date key only) so a future Supabase/Firebase-backed
/// shared cache can replace [SharedPreferencesSaintOfTheDayCache] without
/// any change to `SaintOfTheDayRepositoryImpl`, the domain entity, or the
/// presentation layer — see ADR-0005.
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
    await _prefs.setString(_dateKeyKey, dateKey);
    await _prefs.setString(
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
  }
}
