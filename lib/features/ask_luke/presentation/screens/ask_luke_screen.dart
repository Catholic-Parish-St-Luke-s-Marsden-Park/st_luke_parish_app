import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/config/ask_luke_topics.dart';
import '../providers/selected_ask_luke_topic_provider.dart';
import '../widgets/ask_luke_header.dart';
import '../widgets/ask_luke_message_bubble.dart';
import '../widgets/quick_reply_chip.dart';

/// Full-screen "Ask Luke" quick-reply assistant. No free-text input field,
/// no "Ask me anything…" box, and no send button anywhere on this screen —
/// all 4 responses are hardcoded placeholder copy (see
/// `lib/features/ask_luke/data/config/ask_luke_topics.dart`).
class AskLukeScreen extends ConsumerWidget {
  const AskLukeScreen({super.key});

  static const String _welcomeMessage =
      "Hi, I'm Luke! Tap a topic below and I'll share some information "
      'with you.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTopic = ref.watch(selectedAskLukeTopicProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      // No outer SafeArea: the header's navy gradient runs up behind the
      // status bar so its white icons stay readable.
      body: Column(
        children: [
          const AskLukeHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  const AskLukeMessageBubble(message: _welcomeMessage),
                  if (selectedTopic != null)
                    AskLukeMessageBubble(message: selectedTopic.response),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick topics',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final topic in askLukeTopics)
                          QuickReplyChip(
                            label: topic.label,
                            selected: selectedTopic?.label == topic.label,
                            onTap: () => ref
                                .read(selectedAskLukeTopicProvider.notifier)
                                .select(topic),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
