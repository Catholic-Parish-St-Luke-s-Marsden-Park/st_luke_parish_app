// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saint_of_the_day_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract (REQ-F09-017): the parish API origin
/// comes from `apiBaseUriProvider` and the client from `httpClientProvider`,
/// as in `ministriesRepositoryProvider`. `Future`-typed because
/// `SharedPreferences.getInstance()` is itself async.

@ProviderFor(saintOfTheDayRepository)
final saintOfTheDayRepositoryProvider = SaintOfTheDayRepositoryProvider._();

/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract (REQ-F09-017): the parish API origin
/// comes from `apiBaseUriProvider` and the client from `httpClientProvider`,
/// as in `ministriesRepositoryProvider`. `Future`-typed because
/// `SharedPreferences.getInstance()` is itself async.

final class SaintOfTheDayRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaintOfTheDayRepository>,
          SaintOfTheDayRepository,
          FutureOr<SaintOfTheDayRepository>
        >
    with
        $FutureModifier<SaintOfTheDayRepository>,
        $FutureProvider<SaintOfTheDayRepository> {
  /// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
  /// [SaintOfTheDayRepository] contract (REQ-F09-017): the parish API origin
  /// comes from `apiBaseUriProvider` and the client from `httpClientProvider`,
  /// as in `ministriesRepositoryProvider`. `Future`-typed because
  /// `SharedPreferences.getInstance()` is itself async.
  SaintOfTheDayRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saintOfTheDayRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saintOfTheDayRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SaintOfTheDayRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaintOfTheDayRepository> create(Ref ref) {
    return saintOfTheDayRepository(ref);
  }
}

String _$saintOfTheDayRepositoryHash() =>
    r'19698d290d8d0f48df5d6e3cb3a22f13dbe6ffc6';

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>`. `@riverpod` generates an `AutoDispose...`
/// provider by default; the on-device cache in `data/` (not this provider)
/// is what avoids requesting the same Sydney day from the parish API more
/// than once (REQ-F09-011).

@ProviderFor(saintOfTheDay)
final saintOfTheDayProvider = SaintOfTheDayProvider._();

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>`. `@riverpod` generates an `AutoDispose...`
/// provider by default; the on-device cache in `data/` (not this provider)
/// is what avoids requesting the same Sydney day from the parish API more
/// than once (REQ-F09-011).

final class SaintOfTheDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaintOfTheDay>,
          SaintOfTheDay,
          FutureOr<SaintOfTheDay>
        >
    with $FutureModifier<SaintOfTheDay>, $FutureProvider<SaintOfTheDay> {
  /// Exposes today's saint to [SaintOfTheDayScreen] as
  /// `AsyncValue<SaintOfTheDay>`. `@riverpod` generates an `AutoDispose...`
  /// provider by default; the on-device cache in `data/` (not this provider)
  /// is what avoids requesting the same Sydney day from the parish API more
  /// than once (REQ-F09-011).
  SaintOfTheDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saintOfTheDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saintOfTheDayHash();

  @$internal
  @override
  $FutureProviderElement<SaintOfTheDay> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaintOfTheDay> create(Ref ref) {
    return saintOfTheDay(ref);
  }
}

String _$saintOfTheDayHash() => r'ef4c88c39635cf29a0d166ea723d6f7d369f8b95';
