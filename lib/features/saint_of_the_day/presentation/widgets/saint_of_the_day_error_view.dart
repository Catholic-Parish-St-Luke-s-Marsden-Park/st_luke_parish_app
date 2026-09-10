import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared failure treatment (REQ-F06-011): a user-friendly [message] (no
/// raw exception text) plus an optional retry action. Used for network
/// failures, parsing failures, and the "not configured" (missing API key)
/// state alike — the caller supplies the message text appropriate to the
/// failure kind.
class SaintOfTheDayErrorView extends StatelessWidget {
  const SaintOfTheDayErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

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
