import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';

/// Small pill-shaped chrome button, sized to fit comfortably in an `AppBar`
/// alongside other actions/branding. Reusable across app-level chrome
/// (e.g. "Saint of the Day", "Ask Luke").
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  /// Defaults to the translucent-white chrome style (unchanged for
  /// existing callers, e.g. `AskLukePill`) when not supplied.
  final Color? backgroundColor;

  /// Label/icon color. Defaults to white, matching [backgroundColor]'s
  /// default translucent-dark-navy-AppBar styling, when not supplied.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedForeground = foregroundColor ?? Colors.white;

    return Material(
      color: backgroundColor ?? Colors.white.withValues(alpha: 0.14),
      borderRadius: AppShapes.pillBorderRadius,
      child: InkWell(
        borderRadius: AppShapes.pillBorderRadius,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: backgroundColor != null
                      ? resolvedForeground
                      : AppColors.lightGold,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: resolvedForeground,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
