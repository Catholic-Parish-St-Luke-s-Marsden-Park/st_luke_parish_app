import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ministry.dart';

/// One tappable ministry inside a [MinistryGroupCard]: the name, a
/// "members · day" line and a chevron. The row sizes to its text, so it stays
/// compact at normal text sizes and reflows rather than overflowing when the
/// system text size is increased.
class MinistryRow extends StatelessWidget {
  const MinistryRow({super.key, required this.ministry, required this.onTap});

  final Ministry ministry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = [
      ministry.membersLine,
      ministry.dayLine,
    ].where((part) => part.trim().isNotEmpty).join(' · ');

    // One button for screen readers, announced as "name, subtitle".
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ministry.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              // textSecondary rather than bodySmall's
                              // textMuted, which is under 4.5:1 on white.
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
