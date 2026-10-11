import 'package:shared_preferences/shared_preferences.dart';

/// Holds the last good `GET /v1/ministries` body on the device. Kept narrow,
/// like `SaintOfTheDayCache`, so it can be swapped for another store later.
/// The repository parses what comes back and treats a corrupt entry as a
/// miss.
abstract class MinistriesCache {
  /// The saved response body, or null if nothing has been saved.
  Future<String?> read();

  /// Replaces the saved response body.
  Future<void> write(String json);
}

class SharedPreferencesMinistriesCache implements MinistriesCache {
  SharedPreferencesMinistriesCache(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'ministries_cache_v1';

  @override
  Future<String?> read() async => _prefs.getString(_key);

  @override
  Future<void> write(String json) async {
    await _prefs.setString(_key, json);
  }
}
