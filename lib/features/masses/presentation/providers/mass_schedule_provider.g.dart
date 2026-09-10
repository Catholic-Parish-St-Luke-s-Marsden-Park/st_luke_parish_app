// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mass_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the static Mass schedule to [MassesScreen]. The screen and its
/// widgets read this provider rather than importing
/// `static_mass_schedule_config.dart` directly, so a future scraped/remote
/// data source can be swapped in behind this provider without touching
/// presentation code.

@ProviderFor(massSchedule)
final massScheduleProvider = MassScheduleProvider._();

/// Exposes the static Mass schedule to [MassesScreen]. The screen and its
/// widgets read this provider rather than importing
/// `static_mass_schedule_config.dart` directly, so a future scraped/remote
/// data source can be swapped in behind this provider without touching
/// presentation code.

final class MassScheduleProvider
    extends $FunctionalProvider<MassSchedule, MassSchedule, MassSchedule>
    with $Provider<MassSchedule> {
  /// Exposes the static Mass schedule to [MassesScreen]. The screen and its
  /// widgets read this provider rather than importing
  /// `static_mass_schedule_config.dart` directly, so a future scraped/remote
  /// data source can be swapped in behind this provider without touching
  /// presentation code.
  MassScheduleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'massScheduleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$massScheduleHash();

  @$internal
  @override
  $ProviderElement<MassSchedule> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MassSchedule create(Ref ref) {
    return massSchedule(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MassSchedule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MassSchedule>(value),
    );
  }
}

String _$massScheduleHash() => r'7d17df38cac6eb3640b39ebf4d7cde63d1542f77';
