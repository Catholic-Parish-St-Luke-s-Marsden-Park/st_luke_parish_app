import 'package:flutter/material.dart';

import '../../../shared/widgets/app_pill_button.dart';

/// AppBar pill that shows a hardcoded "coming soon" placeholder for
/// Saint of the Day — no real saint-of-the-day data, date logic, or
/// content lookup exists anywhere in this feature.
class SaintOfTheDayPill extends StatelessWidget {
  const SaintOfTheDayPill({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      label: 'Saint of the Day',
      icon: Icons.auto_awesome_rounded,
      onPressed: () => _showComingSoon(context),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saint of the Day'),
        content: const Text('Coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
