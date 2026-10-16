import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_label.dart';

/// "New to Marsden Park?" welcome card on the Parish tab, just above the
/// parish prayer (moved from the News tab, parish request, 2026-10-16).
class NewToMarsdenParkSection extends StatelessWidget {
  const NewToMarsdenParkSection({super.key});

  static const title = 'New to Marsden Park?';

  static const body =
      "If you've recently moved to Marsden Park, Elara, Colebee or "
      'surrounds, email us at marsdenpark@parracatholic.org with your name '
      'and contact details to stay updated.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Welcome'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: AppShapes.cardBorderRadius,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShapes.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.paleGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.waving_hand_outlined,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AppTypography.display(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
