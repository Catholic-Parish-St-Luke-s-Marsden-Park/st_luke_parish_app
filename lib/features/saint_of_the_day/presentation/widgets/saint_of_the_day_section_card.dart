import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';

/// One labelled content section ("About", "Born & Died", "Famous Saying",
/// etc. — REQ-F06-006). Plain-text label only, no icon/emoji glyph
/// (REQ-F06-013), matching Ask Luke/News/Masses. Sections with empty
/// [body] are not built at all by the caller, not hidden here.
class SaintOfTheDaySectionCard extends StatelessWidget {
  const SaintOfTheDaySectionCard({
    super.key,
    required this.label,
    required this.body,
    this.emphasized = false,
  });

  final String label;
  final String body;

  /// Renders with the navy/gold "emphasized" treatment used for the
  /// closing Prayer section, matching the reference implementation's
  /// visual hierarchy (last section reads as a distinct closing element)
  /// without using its icon/emoji.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: emphasized ? AppColors.heroGradient : null,
        color: emphasized ? null : AppColors.surfaceWhite,
        borderRadius: AppShapes.cardBorderRadius,
        border: emphasized ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            // Both label colours are set for WCAG AA (4.5:1), measured
            // against the worst point of each background:
            //   - textMuted #6B7A99 on white measured 4.31:1 (fails);
            //     textSecondary #4A4A6A measures 8.47:1.
            //   - lightGold #E8C060 measured 3.07:1 against the
            //     lightBlue end of heroGradient (fails); paleGold
            //     #FDF3D0 measures 4.79:1 and stays in the gold family.
            style: textTheme.labelMedium?.copyWith(
              color: emphasized ? AppColors.paleGold : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: emphasized
                  ? Colors.white.withValues(alpha: 0.92)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
