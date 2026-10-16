import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/resource_link.dart';

/// A white card holding one [ResourceGroup]: its title and subtitle, then
/// its rows built by [rowBuilder], separated by thin dividers.
class ResourceGroupCard extends StatelessWidget {
  const ResourceGroupCard({
    super.key,
    required this.group,
    required this.rowBuilder,
  });

  final ResourceGroup group;
  final Widget Function(ResourceLink link) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      // The card colour lives on a Material so the rows' tap ripples show.
      child: Material(
        color: AppColors.surfaceWhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      group.title,
                      style: AppTypography.display(
                        fontSize: 18,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  if (group.subtitle case final subtitle?)
                    Text(
                      subtitle.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.darkGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                ],
              ),
            ),
            for (final (i, link) in group.links.indexed) ...[
              if (i > 0)
                const Divider(height: 1, indent: 70, color: AppColors.border),
              rowBuilder(link),
            ],
          ],
        ),
      ),
    );
  }
}
