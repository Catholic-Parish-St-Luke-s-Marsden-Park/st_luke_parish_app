// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mass_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$massScheduleHash() => r'7d17df38cac6eb3640b39ebf4d7cde63d1542f77';

/// Exposes the static Mass schedule to [MassesScreen]. The screen and its
/// widgets read this provider rather than importing
/// `static_mass_schedule_config.dart` directly, so a future scraped/remote
/// data source can be swapped in behind this provider without touching
/// presentation code.
///
/// Copied from [massSchedule].
@ProviderFor(massSchedule)
final massScheduleProvider = AutoDisposeProvider<MassSchedule>.internal(
  massSchedule,
  name: r'massScheduleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$massScheduleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MassScheduleRef = AutoDisposeProviderRef<MassSchedule>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
