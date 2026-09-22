import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Explicit loading state (REQ-F06-011) — shown while the
/// `saintOfTheDayProvider` future is in flight (first open of the day; a
/// cache hit resolves near-instantly and this view is barely visible).
class SaintOfTheDayLoadingView extends StatelessWidget {
  const SaintOfTheDayLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Finding today's saint…",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
