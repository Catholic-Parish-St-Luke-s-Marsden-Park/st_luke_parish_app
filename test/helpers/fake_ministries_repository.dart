import 'dart:io';

import 'package:st_luke_parish_app/features/ministries/data/datasources/bundled_ministries_source.dart';
import 'package:st_luke_parish_app/features/ministries/data/parsers/ministries_json_parser.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry_category.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';
import 'package:st_luke_parish_app/features/ministries/domain/repositories/ministries_repository.dart';

/// The bundled `assets/ministries_fallback.json`, parsed. Tests run from the
/// project root, so the asset is read straight off disk.
List<MinistryCategory> loadFallbackMinistries() => parseMinistriesJson(
  File(BundledMinistriesSource.assetPath).readAsStringSync(),
);

/// The ministry with [id] from the fallback asset.
Ministry fallbackMinistry(String id) => loadFallbackMinistries()
    .expand((category) => category.ministries)
    .firstWhere((ministry) => ministry.id == id);

/// In-memory [MinistriesRepository] for widget and provider tests. By
/// default it emits the fallback asset once, refreshes successfully to the
/// same list, and answers every by-id lookup with a 404.
class FakeMinistriesRepository implements MinistriesRepository {
  FakeMinistriesRepository({
    Stream<List<MinistryCategory>> Function()? watch,
    List<MinistryCategory>? categories,
    this.refreshed,
    this.refreshFailure,
    this.byId = const {},
    this.byIdFailure,
  }) : _watch =
           watch ??
           (() => Stream.value(categories ?? loadFallbackMinistries()));

  final Stream<List<MinistryCategory>> Function() _watch;

  /// What [refreshMinistries] returns; the fallback asset when null.
  final List<MinistryCategory>? refreshed;

  /// When set, [refreshMinistries] throws it.
  final MinistriesFailure? refreshFailure;

  /// Ministries [getMinistryById] can return.
  final Map<String, Ministry> byId;

  /// What [getMinistryById] throws for ids not in [byId]; a 404 when null.
  final MinistriesFailure? byIdFailure;

  int watchCalls = 0;
  int refreshCalls = 0;
  final List<String> byIdRequests = [];

  @override
  Stream<List<MinistryCategory>> watchMinistries() {
    watchCalls++;
    return _watch();
  }

  @override
  Future<List<MinistryCategory>> refreshMinistries() async {
    refreshCalls++;
    final failure = refreshFailure;
    if (failure != null) throw failure;
    return refreshed ?? loadFallbackMinistries();
  }

  @override
  Future<Ministry> getMinistryById(String id) async {
    byIdRequests.add(id);
    final ministry = byId[id];
    if (ministry != null) return ministry;
    throw byIdFailure ?? MinistryNotFoundFailure('/v1/ministries/$id: 404');
  }
}

/// A [Ministry] with every field derived from [id], for tests that need one
/// that isn't in the fallback asset.
Ministry testMinistry(
  String id, {
  String category = 'Test Category',
  String contactEmail = 'office@example.org',
  String emailSubject = 'Interest',
}) => Ministry(
  id: id,
  category: category,
  name: 'Name $id',
  membersLine: 'Members $id',
  dayLine: 'Day $id',
  tagline: 'Tagline $id',
  time: 'Time $id',
  location: 'Location $id',
  open: 'Open $id',
  about: 'About $id',
  leaderName: 'Leader $id',
  leaderRole: 'Role $id',
  leaderInitials: 'LI',
  joinInfo: 'How to join $id',
  ctaLabel: 'Join $id',
  contactEmail: contactEmail,
  emailSubject: emailSubject,
);
