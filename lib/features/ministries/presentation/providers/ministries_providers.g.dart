// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ministries_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires [MinistriesRepositoryImpl] behind the [MinistriesRepository]
/// contract. `Future`-typed because `SharedPreferences.getInstance()` is
/// async, as in `saintOfTheDayRepositoryProvider`.

@ProviderFor(ministriesRepository)
final ministriesRepositoryProvider = MinistriesRepositoryProvider._();

/// Wires [MinistriesRepositoryImpl] behind the [MinistriesRepository]
/// contract. `Future`-typed because `SharedPreferences.getInstance()` is
/// async, as in `saintOfTheDayRepositoryProvider`.

final class MinistriesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MinistriesRepository>,
          MinistriesRepository,
          FutureOr<MinistriesRepository>
        >
    with
        $FutureModifier<MinistriesRepository>,
        $FutureProvider<MinistriesRepository> {
  /// Wires [MinistriesRepositoryImpl] behind the [MinistriesRepository]
  /// contract. `Future`-typed because `SharedPreferences.getInstance()` is
  /// async, as in `saintOfTheDayRepositoryProvider`.
  MinistriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ministriesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ministriesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<MinistriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MinistriesRepository> create(Ref ref) {
    return ministriesRepository(ref);
  }
}

String _$ministriesRepositoryHash() =>
    r'46034db064696b911b36f1cc86407bc8465ddf95';

/// Ministries grouped by category, in API order. Emits the saved copy first
/// and the fresh one when it arrives (see
/// [MinistriesRepository.watchMinistries]).

@ProviderFor(Ministries)
final ministriesProvider = MinistriesProvider._();

/// Ministries grouped by category, in API order. Emits the saved copy first
/// and the fresh one when it arrives (see
/// [MinistriesRepository.watchMinistries]).
final class MinistriesProvider
    extends $StreamNotifierProvider<Ministries, List<MinistryCategory>> {
  /// Ministries grouped by category, in API order. Emits the saved copy first
  /// and the fresh one when it arrives (see
  /// [MinistriesRepository.watchMinistries]).
  MinistriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ministriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ministriesHash();

  @$internal
  @override
  Ministries create() => Ministries();
}

String _$ministriesHash() => r'329beb6f5a3c7b01a6a21ff1d30c2afdd4ba9b34';

/// Ministries grouped by category, in API order. Emits the saved copy first
/// and the fresh one when it arrives (see
/// [MinistriesRepository.watchMinistries]).

abstract class _$Ministries extends $StreamNotifier<List<MinistryCategory>> {
  Stream<List<MinistryCategory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MinistryCategory>>, List<MinistryCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MinistryCategory>>,
                List<MinistryCategory>
              >,
              AsyncValue<List<MinistryCategory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A single ministry for the detail screen: taken from the loaded list when
/// it's there, otherwise fetched by id (e.g. a future deep link). Throws
/// [MinistryNotFoundFailure] for an unknown or hidden id.

@ProviderFor(ministryById)
final ministryByIdProvider = MinistryByIdFamily._();

/// A single ministry for the detail screen: taken from the loaded list when
/// it's there, otherwise fetched by id (e.g. a future deep link). Throws
/// [MinistryNotFoundFailure] for an unknown or hidden id.

final class MinistryByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Ministry>, Ministry, FutureOr<Ministry>>
    with $FutureModifier<Ministry>, $FutureProvider<Ministry> {
  /// A single ministry for the detail screen: taken from the loaded list when
  /// it's there, otherwise fetched by id (e.g. a future deep link). Throws
  /// [MinistryNotFoundFailure] for an unknown or hidden id.
  MinistryByIdProvider._({
    required MinistryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ministryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ministryByIdHash();

  @override
  String toString() {
    return r'ministryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Ministry> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Ministry> create(Ref ref) {
    final argument = this.argument as String;
    return ministryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MinistryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ministryByIdHash() => r'a2ced2dce131571d5cccc45a59414c04818b01f3';

/// A single ministry for the detail screen: taken from the loaded list when
/// it's there, otherwise fetched by id (e.g. a future deep link). Throws
/// [MinistryNotFoundFailure] for an unknown or hidden id.

final class MinistryByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Ministry>, String> {
  MinistryByIdFamily._()
    : super(
        retry: null,
        name: r'ministryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single ministry for the detail screen: taken from the loaded list when
  /// it's there, otherwise fetched by id (e.g. a future deep link). Throws
  /// [MinistryNotFoundFailure] for an unknown or hidden id.

  MinistryByIdProvider call(String id) =>
      MinistryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'ministryByIdProvider';
}
