import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';

/// Rounded card container for the Events section's content — same visual
/// treatment as `NewsCard`/`MassCard`, duplicated rather than imported
/// cross-feature, per CLAUDE.md's "keep feature concerns isolated" rule
/// (the same precedent `NewsCard`'s own doc comment cites).
class EventsCard extends StatelessWidget {
  const EventsCard({super.key, required this.child, this.padding});

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
