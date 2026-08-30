import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Hero banner for the Masses tab: eyebrow label + "Mass Times" title only
/// (no address/location subtitle — REQ-F04-002).
class MassesHeroBanner extends StatelessWidget {
  const MassesHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ST LUKE'S · MARSDEN PARK",
            style: AppTypography.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mass Times',
            style: AppTypography.display(
              fontSize: 26,
              height: 1.25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
