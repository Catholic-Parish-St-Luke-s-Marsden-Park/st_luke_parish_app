import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/ministry.dart';
import 'ministry_row.dart';

/// White rounded card listing one category's ministries as [MinistryRow]s
/// separated by hairlines. Same surface styling as the Masses tab's
/// `MassCard`.
class MinistryGroupCard extends StatelessWidget {
  const MinistryGroupCard({
    super.key,
    required this.ministries,
    required this.onTap,
  });

  final List<Ministry> ministries;
  final ValueChanged<Ministry> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      child: Material(
        color: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        // Keeps the row ink splash inside the rounded corners.
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < ministries.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  color: AppColors.border,
                ),
              MinistryRow(
                ministry: ministries[i],
                onTap: () => onTap(ministries[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
