// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the Rosary and the Chaplet remember the step reached. `Future`-typed
/// because `SharedPreferences.getInstance()` is async.

@ProviderFor(prayerProgressStore)
final prayerProgressStoreProvider = PrayerProgressStoreProvider._();

/// Where the Rosary and the Chaplet remember the step reached. `Future`-typed
/// because `SharedPreferences.getInstance()` is async.

final class PrayerProgressStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrayerProgressStore>,
          PrayerProgressStore,
          FutureOr<PrayerProgressStore>
        >
    with
        $FutureModifier<PrayerProgressStore>,
        $FutureProvider<PrayerProgressStore> {
  /// Where the Rosary and the Chaplet remember the step reached. `Future`-typed
  /// because `SharedPreferences.getInstance()` is async.
  PrayerProgressStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prayerProgressStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prayerProgressStoreHash();

  @$internal
  @override
  $FutureProviderElement<PrayerProgressStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrayerProgressStore> create(Ref ref) {
    return prayerProgressStore(ref);
  }
}

String _$prayerProgressStoreHash() =>
    r'a95671eb91d7a1c80a8e1da242005a874b7da076';
