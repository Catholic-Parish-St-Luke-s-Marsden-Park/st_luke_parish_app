import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/giving_area.dart';

IconData _icon(GivingAreaKind kind) => switch (kind) {
  GivingAreaKind.staffing => Icons.groups_outlined,
  GivingAreaKind.facilities => Icons.home_work_outlined,
  GivingAreaKind.sacramental => Icons.wine_bar_outlined,
  GivingAreaKind.formation => Icons.school_outlined,
  GivingAreaKind.buildingFund => Icons.construction_outlined,
};

/// One area a gift supports: its icon and title, which pull down to show
/// the description (so the card stays short).
class GivingAreaRow extends StatelessWidget {
  const GivingAreaRow({super.key, required this.area});

  final GivingArea area;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Transparent Material so the tile's ripple shows on the white card;
    // the Theme drops ExpansionTile's divider lines.
    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(48, 0, 8, 10),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.primaryNavy,
          leading: ExcludeSemantics(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.paleGold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon(area.kind),
                color: AppColors.primaryNavy,
                size: 20,
              ),
            ),
          ),
          title: Text(
            area.title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primaryNavy,
            ),
          ),
          children: [
            Text(
              area.description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
