import 'dart:developer' as developer;

import '../../domain/entities/ministry.dart';
import '../../domain/entities/ministry_category.dart';
import '../../domain/failures/ministries_failure.dart';
import '../../domain/repositories/ministries_repository.dart';
import '../cache/ministries_cache.dart';
import '../datasources/bundled_ministries_source.dart';
import '../datasources/ministries_remote_datasource.dart';
import '../parsers/ministries_json_parser.dart';

/// Loads ministries stale-while-revalidate: the saved copy first, then the
/// network, with the bundled snapshot as the last resort when nothing has
/// ever been saved. The bundled copy is never written to the cache, so the
/// cache only ever holds a real API response.
class MinistriesRepositoryImpl implements MinistriesRepository {
  MinistriesRepositoryImpl(this._remote, this._cache, this._bundled);

  final MinistriesRemoteDatasource _remote;
  final MinistriesCache _cache;
  final BundledMinistriesSource _bundled;

  @override
  Stream<List<MinistryCategory>> watchMinistries() async* {
    final cached = await _readCache();
    if (cached != null) yield cached;

    try {
      yield await refreshMinistries();
    } on MinistriesFailure catch (e) {
      _log(
        'Refresh failed; showing the '
        '${cached == null ? 'bundled' : 'saved'} copy: $e',
      );
      if (cached == null) yield await _loadBundled();
    }
  }

  @override
  Future<List<MinistryCategory>> refreshMinistries() async {
    final json = await _remote.fetchMinistriesJson();
    final categories = parseMinistriesJson(json);
    await _writeCache(json);
    return categories;
  }

  @override
  Future<Ministry> getMinistryById(String id) async =>
      parseMinistryJson(await _remote.fetchMinistryJson(id));

  Future<List<MinistryCategory>?> _readCache() async {
    try {
      final json = await _cache.read();
      return json == null ? null : parseMinistriesJson(json);
    } catch (e) {
      // A corrupt or unreadable entry is a miss, not a crash; the network
      // or bundled copy replaces it.
      _log('Ignoring the saved copy: $e');
      return null;
    }
  }

  Future<void> _writeCache(String json) async {
    // Best-effort, like the saint cache: a failed write must not throw away
    // a good response that has already been fetched.
    try {
      await _cache.write(json);
    } catch (e) {
      _log('Failed to save ministries: $e');
    }
  }

  Future<List<MinistryCategory>> _loadBundled() async {
    final String json;
    try {
      json = await _bundled.loadJson();
    } catch (e) {
      throw MinistriesParsingFailure('Bundled ministries failed to load: $e');
    }
    return parseMinistriesJson(json);
  }

  void _log(String message) =>
      developer.log(message, name: 'MinistriesRepository');
}
