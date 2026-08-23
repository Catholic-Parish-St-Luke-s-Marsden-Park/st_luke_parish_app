// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedNavIndexHash() => r'fdf9d353843dee806e2a4b4b8fb3eb3f01a13276';

/// Tracks the selected bottom-navigation tab index for [AppShell].
///
/// This is a minimal example of app-level Riverpod state generated via
/// `riverpod_generator`; feature-specific state should live in each
/// feature's own `presentation/providers/` folder.
///
/// Copied from [SelectedNavIndex].
@ProviderFor(SelectedNavIndex)
final selectedNavIndexProvider =
    AutoDisposeNotifierProvider<SelectedNavIndex, int>.internal(
      SelectedNavIndex.new,
      name: r'selectedNavIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedNavIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedNavIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
