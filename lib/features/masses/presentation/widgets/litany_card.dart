import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/litany_config.dart';

/// The Litany of the Blessed Virgin Mary as its own pull-down card on The
/// Rosary page: each call with its response, then the closing prayer
/// (parish request, 2026-10-18).
class LitanyCard extends StatelessWidget {
  const LitanyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final callStyle = textTheme.bodyLarge?.copyWith(
      color: AppColors.primaryNavy,
      height: 1.5,
    );
    final responseStyle = TextStyle(
      color: AppColors.darkGold,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      child: Material(
        color: AppColors.surfaceWhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.gold, width: 8)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.primaryNavy,
              title: Text(
                litanyTitle,
                style: AppTypography.display(
                  fontSize: 19,
                  color: AppColors.primaryNavy,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Each call with its response',
                  style: textTheme.bodySmall,
                ),
              ),
              children: [
                for (final line in litanyLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${line.call} '),
                          TextSpan(text: line.response, style: responseStyle),
                        ],
                      ),
                      style: callStyle,
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paleGold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        litanyClosingPrayer.name,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        litanyClosingPrayer.text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
