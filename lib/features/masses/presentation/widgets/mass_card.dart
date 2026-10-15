import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';

/// Rounded card container for one "What's On" Mass times card, e.g.
/// "Weekend Mass Times". Plain content only — no icons, no tap
/// affordance (REQ-F04-011, REQ-F04-012).
class MassCard extends StatelessWidget {
  const MassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
