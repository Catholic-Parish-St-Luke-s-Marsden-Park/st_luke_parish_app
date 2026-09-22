// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the selected bottom-navigation tab index for [AppShell].
///
/// This is a minimal example of app-level Riverpod state generated via
/// `riverpod_generator`; feature-specific state should live in each
/// feature's own `presentation/providers/` folder.

@ProviderFor(SelectedNavIndex)
final selectedNavIndexProvider = SelectedNavIndexProvider._();

/// Tracks the selected bottom-navigation tab index for [AppShell].
///
/// This is a minimal example of app-level Riverpod state generated via
/// `riverpod_generator`; feature-specific state should live in each
/// feature's own `presentation/providers/` folder.
final class SelectedNavIndexProvider
    extends $NotifierProvider<SelectedNavIndex, int> {
  /// Tracks the selected bottom-navigation tab index for [AppShell].
  ///
  /// This is a minimal example of app-level Riverpod state generated via
  /// `riverpod_generator`; feature-specific state should live in each
  /// feature's own `presentation/providers/` folder.
  SelectedNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNavIndexHash();

  @$internal
  @override
  SelectedNavIndex create() => SelectedNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedNavIndexHash() => r'fdf9d353843dee806e2a4b4b8fb3eb3f01a13276';

/// Tracks the selected bottom-navigation tab index for [AppShell].
///
/// This is a minimal example of app-level Riverpod state generated via
/// `riverpod_generator`; feature-specific state should live in each
/// feature's own `presentation/providers/` folder.

abstract class _$SelectedNavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
