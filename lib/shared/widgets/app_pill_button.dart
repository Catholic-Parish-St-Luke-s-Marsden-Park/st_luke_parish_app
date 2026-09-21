import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';

/// Small pill-shaped chrome button, sized to fit comfortably in an `AppBar`
/// alongside other actions/branding. Reusable across app-level chrome
/// (e.g. "Saint of the Day", "Ask Luke").
///
/// The coloured pill stays visually compact while the *tap target* around
/// it is held to [minTapTarget], per the accessibility rules in
/// CLAUDE.md. The two are deliberately separate: growing the pill itself
/// to 48 logical pixels would fill almost all of a 56dp AppBar.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Minimum interactive size. CLAUDE.md: "Interactive targets must be at
  /// least 48x48 logical pixels."
  static const double minTapTarget = 48;

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

    // The icon follows [foregroundColor] whenever one is supplied.
    // Previously it only did so when [backgroundColor] was *also*
    // supplied, so a caller setting just [foregroundColor] got a
    // recoloured label sitting beside a still-gold icon. No current
    // caller hits that combination, but the two parameters read as
    // independent in the public API and should behave that way.
    final resolvedIcon =
        foregroundColor ??
        (backgroundColor != null ? Colors.white : AppColors.lightGold);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppShapes.pillBorderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTapTarget,
            minHeight: minTapTarget,
          ),
          // Both factors are 1 so the coloured pill shrink-wraps its
          // content on each axis and only the ConstrainedBox above
          // decides the hit area. Without `heightFactor` this Center
          // expands to whatever height the parent allows — harmless in a
          // 56dp AppBar, but 600dp tall in a loose parent.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white.withValues(alpha: 0.14),
                borderRadius: AppShapes.pillBorderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 13, color: resolvedIcon),
                      const SizedBox(width: 4),
                    ],
                    // Flexible so the label ellipsizes when the AppBar
                    // runs out of room (two pills beside the logo on a
                    // 360dp phone, or any text scale above 1.0) instead
                    // of overflowing the toolbar. Requires the call site
                    // to give this widget bounded width — `AppShell`
                    // wraps each pill in a Flexible for that reason.
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: resolvedForeground,
                          // 12 is the project's documented floor for
                          // hardcoded sizes; this was 11.
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
