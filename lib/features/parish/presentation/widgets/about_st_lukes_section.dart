import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_label.dart';

/// "About St Luke's" section. Deliberately renders no icon/logo row above
/// or near it (REQ-F02-010) — only the section heading and body copy.
class AboutStLukesSection extends StatelessWidget {
  const AboutStLukesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel("Our Story"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: AppShapes.cardBorderRadius,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShapes.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About St Luke's",
                style: AppTypography.display(fontSize: 17),
              ),
              const SizedBox(height: 10),
              Text(
                "St Luke's was formed on 1 January 2018 in response to the "
                "rapid growth of Sydney's northwest. From a community of "
                '150, we have grown to over 600 parishioners from Marsden '
                'Park, Elara, Colebee and surrounds.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'In October 2025, our purpose-built parish building was '
                'opened and blessed on the Feast of St Luke — located at '
                'the corner of Frontier Avenue and Northbourne Drive.',
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
    );
  }
}
