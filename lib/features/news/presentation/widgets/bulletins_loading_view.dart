import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Explicit loading state for the bulletins section (REQ-F05-016) — shown
/// while the `bulletinsProvider` future is in flight.
class BulletinsLoadingView extends StatelessWidget {
  const BulletinsLoadingView({super.key});

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
            'Loading the latest bulletins…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
