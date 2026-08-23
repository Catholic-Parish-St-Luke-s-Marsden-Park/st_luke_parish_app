import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_index_provider.g.dart';

/// Tracks the selected bottom-navigation tab index for [AppShell].
///
/// This is a minimal example of app-level Riverpod state generated via
/// `riverpod_generator`; feature-specific state should live in each
/// feature's own `presentation/providers/` folder.
@riverpod
class SelectedNavIndex extends _$SelectedNavIndex {
  @override
  int build() => 0;

  void select(int index) => state = index;
}
