// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulletins_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bulletinsRepositoryHash() =>
    r'bdc7ff73756a8cf21071788dfd00d1051927b75c';

/// Wires the concrete [FeedBulletinsRepository] behind the abstract
/// [BulletinsRepository] contract, so a future scraped/remote data source
/// can be swapped in later without touching presentation code (same pattern
/// as `massScheduleProvider`).
///
/// Copied from [bulletinsRepository].
@ProviderFor(bulletinsRepository)
final bulletinsRepositoryProvider =
    AutoDisposeProvider<BulletinsRepository>.internal(
      bulletinsRepository,
      name: r'bulletinsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bulletinsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BulletinsRepositoryRef = AutoDisposeProviderRef<BulletinsRepository>;
String _$bulletinsHash() => r'82701c8e359df1791e09de52caf3a4d20a724f1e';

/// Exposes bulletins to [NewsScreen] as `AsyncValue<List<Bulletin>>`
/// (REQ-F05-014). `@riverpod` generates an `AutoDispose...` provider by
/// default — no caching across screen entries, matching REQ-F05-014's
/// "no cross-screen-entry caching" requirement and CLAUDE.md's "no local
/// persistence until there's a clear requirement" rule.
///
/// Copied from [bulletins].
@ProviderFor(bulletins)
final bulletinsProvider = AutoDisposeFutureProvider<List<Bulletin>>.internal(
  bulletins,
  name: r'bulletinsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bulletinsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BulletinsRef = AutoDisposeFutureProviderRef<List<Bulletin>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
