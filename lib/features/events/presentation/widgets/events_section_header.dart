import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Upcoming Events" section title — kept local to the Events feature
/// rather than reusing `NewsSectionHeader`, matching the feature-isolation
/// precedent `NewsSectionHeader` itself cites (`MassSectionHeader`).
class EventsSectionHeader extends StatelessWidget {
  const EventsSectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.primaryNavy),
      ),
    );
  }
}
