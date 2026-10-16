import 'dart:developer' as developer;

import '../../../../core/constants/external_links.dart';
import '../../domain/entities/monthly_reflection.dart';
import '../../domain/failures/reflections_failure.dart';
import '../../domain/repositories/reflections_repository.dart';
import '../datasources/reflections_page_datasource.dart';
import '../parsers/monthly_reflections_parser.dart';

/// Finds this month's Daily Readings & Reflections on the Risen Lord
/// Community's page, or the newest booklet already out if this month's
/// isn't listed yet.
class WebsiteReflectionsRepository implements ReflectionsRepository {
  WebsiteReflectionsRepository(this._datasource, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ReflectionsPageDatasource _datasource;
  final DateTime Function() _now;

  @override
  Future<MonthlyReflection> getLatestReflection() async {
    try {
      final html = await _datasource.fetchPageHtml();
      final reflections = parseMonthlyReflections(
        html,
        baseUri: Uri.parse(ExternalLinks.dailyReflectionsPage),
      ).where((r) => _isValidUrl(r.url)).toList();
      if (reflections.isEmpty) {
        throw const ReflectionsParsingFailure(
          'No monthly reflection links on the reflections page',
        );
      }

      final today = _now();
      final thisMonth = DateTime(today.year, today.month);
      // Newest first; skip any booklet listed ahead of time for a later
      // month, unless that is all there is.
      reflections.sort((a, b) => b.month.compareTo(a.month));
      return reflections.firstWhere(
        (r) => !r.month.isAfter(thisMonth),
        orElse: () => reflections.last,
      );
    } on ReflectionsFailure catch (e) {
      _log('$e');
      rethrow;
    } catch (e) {
      final failure = ReflectionsParsingFailure(
        'Unexpected error reading the reflections page: $e',
      );
      _log('$failure');
      throw failure;
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  void _log(String message) =>
      developer.log(message, name: 'ReflectionsRepository');
}
