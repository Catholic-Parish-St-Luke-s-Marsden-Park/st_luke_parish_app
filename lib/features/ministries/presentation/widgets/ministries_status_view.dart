import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Loading state for the Ministries tab and detail screen.
class MinistriesLoadingView extends StatelessWidget {
  const MinistriesLoadingView({super.key, required this.caption});

  final String caption;

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
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Empty and error states: a user-friendly [message] (never raw exception
/// text) plus an optional "Try again" action with a 48x48 minimum target.
class MinistriesMessageView extends StatelessWidget {
  const MinistriesMessageView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Try again',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
