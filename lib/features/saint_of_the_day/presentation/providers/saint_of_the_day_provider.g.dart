// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saint_of_the_day_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract, so a future Supabase-backed cache
/// (see ADR-0005) can be swapped in later without touching presentation
/// code — same pattern as `bulletinsRepositoryProvider`. `Future`-typed
/// because `SharedPreferences.getInstance()` is itself async.

@ProviderFor(saintOfTheDayRepository)
final saintOfTheDayRepositoryProvider = SaintOfTheDayRepositoryProvider._();

/// Wires the concrete [SaintOfTheDayRepositoryImpl] behind the abstract
/// [SaintOfTheDayRepository] contract, so a future Supabase-backed cache
/// (see ADR-0005) can be swapped in later without touching presentation
/// code — same pattern as `bulletinsRepositoryProvider`. `Future`-typed
/// because `SharedPreferences.getInstance()` is itself async.

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
  /// [SaintOfTheDayRepository] contract, so a future Supabase-backed cache
  /// (see ADR-0005) can be swapped in later without touching presentation
  /// code — same pattern as `bulletinsRepositoryProvider`. `Future`-typed
  /// because `SharedPreferences.getInstance()` is itself async.
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
    r'f2291e27e3f4bdaaaf03a61fd0996b49d2076487';

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>` (REQ-F06-011). `@riverpod` generates an
/// `AutoDispose...` provider by default; the on-device cache in `data/`
/// (not this provider) is what avoids re-calling OpenRouter more than once
/// per Sydney calendar day (REQ-F06-008).

@ProviderFor(saintOfTheDay)
final saintOfTheDayProvider = SaintOfTheDayProvider._();

/// Exposes today's saint to [SaintOfTheDayScreen] as
/// `AsyncValue<SaintOfTheDay>` (REQ-F06-011). `@riverpod` generates an
/// `AutoDispose...` provider by default; the on-device cache in `data/`
/// (not this provider) is what avoids re-calling OpenRouter more than once
/// per Sydney calendar day (REQ-F06-008).

final class SaintOfTheDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaintOfTheDay>,
          SaintOfTheDay,
          FutureOr<SaintOfTheDay>
        >
    with $FutureModifier<SaintOfTheDay>, $FutureProvider<SaintOfTheDay> {
  /// Exposes today's saint to [SaintOfTheDayScreen] as
  /// `AsyncValue<SaintOfTheDay>` (REQ-F06-011). `@riverpod` generates an
  /// `AutoDispose...` provider by default; the on-device cache in `data/`
  /// (not this provider) is what avoids re-calling OpenRouter more than once
  /// per Sydney calendar day (REQ-F06-008).
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
