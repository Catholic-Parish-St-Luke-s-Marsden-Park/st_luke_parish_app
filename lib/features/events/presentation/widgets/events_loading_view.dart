import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Explicit loading state for the Events section/screen (REQ-F08-014) —
/// shown while `upcomingEventsProvider`'s future is in flight. Mirrors
/// `BulletinsLoadingView`'s shape exactly.
class EventsLoadingView extends StatelessWidget {
  const EventsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading upcoming events…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
