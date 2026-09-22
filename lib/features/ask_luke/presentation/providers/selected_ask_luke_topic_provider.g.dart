// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_ask_luke_topic_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks which [AskLukeTopic] quick-reply chip (if any) the user has
/// tapped on [AskLukeScreen], so its response can be shown on screen.

@ProviderFor(SelectedAskLukeTopic)
final selectedAskLukeTopicProvider = SelectedAskLukeTopicProvider._();

/// Tracks which [AskLukeTopic] quick-reply chip (if any) the user has
/// tapped on [AskLukeScreen], so its response can be shown on screen.
final class SelectedAskLukeTopicProvider
    extends $NotifierProvider<SelectedAskLukeTopic, AskLukeTopic?> {
  /// Tracks which [AskLukeTopic] quick-reply chip (if any) the user has
  /// tapped on [AskLukeScreen], so its response can be shown on screen.
  SelectedAskLukeTopicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAskLukeTopicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAskLukeTopicHash();

  @$internal
  @override
  SelectedAskLukeTopic create() => SelectedAskLukeTopic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AskLukeTopic? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AskLukeTopic?>(value),
    );
  }
}

String _$selectedAskLukeTopicHash() =>
    r'f2b10de8095fa039ca25579f3bb75c7a2db502e7';

/// Tracks which [AskLukeTopic] quick-reply chip (if any) the user has
/// tapped on [AskLukeScreen], so its response can be shown on screen.

abstract class _$SelectedAskLukeTopic extends $Notifier<AskLukeTopic?> {
  AskLukeTopic? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AskLukeTopic?, AskLukeTopic?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AskLukeTopic?, AskLukeTopic?>,
              AskLukeTopic?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
