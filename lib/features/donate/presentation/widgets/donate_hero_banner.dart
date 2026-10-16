import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/donate_config.dart';

/// Hero banner for the Donate tab, in the same style as the other tabs'.
class DonateHeroBanner extends StatelessWidget {
  const DonateHeroBanner({super.key});

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
            'SUPPORT OUR PARISH',
            style: AppTypography.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              'Donate',
              style: AppTypography.display(
                fontSize: 26,
                height: 1.25,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DonateConfig.heading,
            style: AppTypography.body(
              fontSize: 14,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
