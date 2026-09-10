// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulletins_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the concrete [FeedBulletinsRepository] behind the abstract
/// [BulletinsRepository] contract, so a future scraped/remote data source
/// can be swapped in later without touching presentation code (same pattern
/// as `massScheduleProvider`).

@ProviderFor(bulletinsRepository)
final bulletinsRepositoryProvider = BulletinsRepositoryProvider._();

/// Wires the concrete [FeedBulletinsRepository] behind the abstract
/// [BulletinsRepository] contract, so a future scraped/remote data source
/// can be swapped in later without touching presentation code (same pattern
/// as `massScheduleProvider`).

final class BulletinsRepositoryProvider
    extends
        $FunctionalProvider<
          BulletinsRepository,
          BulletinsRepository,
          BulletinsRepository
        >
    with $Provider<BulletinsRepository> {
  /// Wires the concrete [FeedBulletinsRepository] behind the abstract
  /// [BulletinsRepository] contract, so a future scraped/remote data source
  /// can be swapped in later without touching presentation code (same pattern
  /// as `massScheduleProvider`).
  BulletinsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulletinsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulletinsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BulletinsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BulletinsRepository create(Ref ref) {
    return bulletinsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BulletinsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BulletinsRepository>(value),
    );
  }
}

String _$bulletinsRepositoryHash() =>
    r'bdc7ff73756a8cf21071788dfd00d1051927b75c';

/// Exposes bulletins to [NewsScreen] as `AsyncValue<List<Bulletin>>`
/// (REQ-F05-014). `@riverpod` generates an `AutoDispose...` provider by
/// default — no caching across screen entries, matching REQ-F05-014's
/// "no cross-screen-entry caching" requirement and CLAUDE.md's "no local
/// persistence until there's a clear requirement" rule.

@ProviderFor(bulletins)
final bulletinsProvider = BulletinsProvider._();

/// Exposes bulletins to [NewsScreen] as `AsyncValue<List<Bulletin>>`
/// (REQ-F05-014). `@riverpod` generates an `AutoDispose...` provider by
/// default — no caching across screen entries, matching REQ-F05-014's
/// "no cross-screen-entry caching" requirement and CLAUDE.md's "no local
/// persistence until there's a clear requirement" rule.

final class BulletinsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bulletin>>,
          List<Bulletin>,
          FutureOr<List<Bulletin>>
        >
    with $FutureModifier<List<Bulletin>>, $FutureProvider<List<Bulletin>> {
  /// Exposes bulletins to [NewsScreen] as `AsyncValue<List<Bulletin>>`
  /// (REQ-F05-014). `@riverpod` generates an `AutoDispose...` provider by
  /// default — no caching across screen entries, matching REQ-F05-014's
  /// "no cross-screen-entry caching" requirement and CLAUDE.md's "no local
  /// persistence until there's a clear requirement" rule.
  BulletinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulletinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulletinsHash();

  @$internal
  @override
  $FutureProviderElement<List<Bulletin>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Bulletin>> create(Ref ref) {
    return bulletins(ref);
  }
}

String _$bulletinsHash() => r'82701c8e359df1791e09de52caf3a4d20a724f1e';
