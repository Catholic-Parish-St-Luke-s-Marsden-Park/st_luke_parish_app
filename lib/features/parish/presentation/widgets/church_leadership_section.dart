import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/church_leadership_config.dart';
import 'leadership_entry_tile.dart';
import 'section_label.dart';

/// The 3-part "Church Leadership" section: Universal Church, Diocese of
/// Parramatta, Parish (Parish has exactly 2 rows: Parish Priest, Parish
/// Secretary). Replaces the reference site's separate "Parish Leadership"
/// and "Diocese of Parramatta" cards with a single combined section.
class ChurchLeadershipSectionWidget extends StatelessWidget {
  const ChurchLeadershipSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Church Leadership'),
        for (final section in churchLeadershipSections)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: AppShapes.cardBorderRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShapes.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title, style: AppTypography.display(fontSize: 15)),
                for (final entry in section.entries)
                  LeadershipEntryTile(entry: entry),
              ],
            ),
          ),
      ],
    );
  }
}
