import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';

/// Rounded card container grouping one News-tab section's content
/// (bulletins, announcements, or the prayer intentions card) — same visual
/// treatment as `MassCard`, kept local to this feature per CLAUDE.md's
/// "keep feature concerns isolated" rule.
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppShapes.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShapes.cardShadow,
      ),
      child: child,
    );
  }
}
