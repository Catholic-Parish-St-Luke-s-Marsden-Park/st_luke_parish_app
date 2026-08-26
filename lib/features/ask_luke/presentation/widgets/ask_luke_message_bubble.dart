import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';

/// A single message bubble used for both the welcome message and topic
/// responses on [AskLukeScreen].
class AskLukeMessageBubble extends StatelessWidget {
  const AskLukeMessageBubble({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppShapes.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShapes.cardShadow,
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
