import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Hero banner for the News tab: eyebrow + "News & Bulletins" title +
/// subtitle, matching the approved mockup and the styling precedent set by
/// `MassesHeroBanner`.
class NewsHeroBanner extends StatelessWidget {
  const NewsHeroBanner({super.key});

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
            'STAY CONNECTED',
            style: AppTypography.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'News & Bulletins',
            style: AppTypography.display(
              fontSize: 26,
              height: 1.25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Keep up with what's happening in our parish community.",
            style: AppTypography.body(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
