import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';

/// Visual style for [CtaPillButton].
enum CtaPillButtonStyle { gold, navy }

/// Solid, gradient-filled pill CTA button for use on page content (e.g. the
/// Ministries "Join Us" CTA, the Contact "Open in Google Maps" button).
///
/// Distinct from [AppPillButton]: [AppPillButton] is a translucent-white
/// pill meant to sit on top of the navy `AppBar` chrome, which would be
/// low-contrast/unreadable on the light page backgrounds this button is
/// used on.
class CtaPillButton extends StatelessWidget {
  const CtaPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = CtaPillButtonStyle.gold,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CtaPillButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final gradient = style == CtaPillButtonStyle.gold
        ? AppColors.goldGradient
        : AppColors.heroGradient;
    final textColor = style == CtaPillButtonStyle.gold
        ? AppColors.textPrimary
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppShapes.pillBorderRadius,
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppShapes.pillBorderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 6),
              ],
              // Flexible, so a long label wraps on a narrow screen or at a
              // large text size instead of overflowing.
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
