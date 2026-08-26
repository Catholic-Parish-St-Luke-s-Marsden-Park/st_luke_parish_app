import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/ask_luke_topic.dart';

part 'selected_ask_luke_topic_provider.g.dart';

/// Tracks which [AskLukeTopic] quick-reply chip (if any) the user has
/// tapped on [AskLukeScreen], so its response can be shown on screen.
@riverpod
class SelectedAskLukeTopic extends _$SelectedAskLukeTopic {
  @override
  AskLukeTopic? build() => null;

  void select(AskLukeTopic topic) => state = topic;
}
