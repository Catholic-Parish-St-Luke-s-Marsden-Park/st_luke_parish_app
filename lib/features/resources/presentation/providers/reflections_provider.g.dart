// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflections_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the website-backed repository behind the abstract contract.

@ProviderFor(reflectionsRepository)
final reflectionsRepositoryProvider = ReflectionsRepositoryProvider._();

/// Wires the website-backed repository behind the abstract contract.

final class ReflectionsRepositoryProvider
    extends
        $FunctionalProvider<
          ReflectionsRepository,
          ReflectionsRepository,
          ReflectionsRepository
        >
    with $Provider<ReflectionsRepository> {
  /// Wires the website-backed repository behind the abstract contract.
  ReflectionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reflectionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reflectionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReflectionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReflectionsRepository create(Ref ref) {
    return reflectionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReflectionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReflectionsRepository>(value),
    );
  }
}

String _$reflectionsRepositoryHash() =>
    r'883279293d4bdbc3a0b67da3348532680d262c26';

/// The current Daily Readings & Reflections booklet. Auto-disposed, so it
/// is read afresh each time the Resources page opens.

@ProviderFor(latestReflection)
final latestReflectionProvider = LatestReflectionProvider._();

/// The current Daily Readings & Reflections booklet. Auto-disposed, so it
/// is read afresh each time the Resources page opens.

final class LatestReflectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthlyReflection>,
          MonthlyReflection,
          FutureOr<MonthlyReflection>
        >
    with
        $FutureModifier<MonthlyReflection>,
        $FutureProvider<MonthlyReflection> {
  /// The current Daily Readings & Reflections booklet. Auto-disposed, so it
  /// is read afresh each time the Resources page opens.
  LatestReflectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestReflectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestReflectionHash();

  @$internal
  @override
  $FutureProviderElement<MonthlyReflection> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MonthlyReflection> create(Ref ref) {
    return latestReflection(ref);
  }
}

String _$latestReflectionHash() => r'f9802c4bb48b68909bc213c29d429de5c6b9a39d';
