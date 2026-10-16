import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_activity.dart';
import 'parish_activity_icon.dart';

/// One collapsible "Regular Activities" ribbon: icon and title when
/// collapsed; tapping it pulls down the When / Where / Who details, the
/// description, the contact and an optional link button.
class ActivityRibbon extends ConsumerWidget {
  const ActivityRibbon({super.key, required this.activity});

  final ParishActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      // The card colour lives on a Material so the tile's tap ripple shows.
      child: Material(
        color: AppColors.surfaceWhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        child: Theme(
          // Drops ExpansionTile's top/bottom divider lines inside the card.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.paleGold,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: parishActivityIcon(
                  activity.kind,
                  color: AppColors.primaryNavy,
                  size: 22,
                ),
              ),
            ),
            title: Text(
              activity.title,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primaryNavy,
              ),
            ),
            iconColor: AppColors.gold,
            collapsedIconColor: AppColors.primaryNavy,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              if (activity.when case final schedule?)
                _ActivityDetail(
                  icon: Icons.schedule,
                  label: 'When',
                  value: schedule,
                ),
              if (activity.where case final where?)
                _ActivityDetail(
                  icon: Icons.place_outlined,
                  label: 'Where',
                  value: where,
                ),
              if (activity.who case final who?)
                _ActivityDetail(
                  icon: Icons.person_outline,
                  label: 'Who',
                  value: who,
                ),
              if (activity.description case final description?)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              if (activity.contact case final contact?)
                _ActivityDetail(
                  icon: Icons.mail_outline,
                  label: 'Contact',
                  value: contact,
                ),
              if (activity.link case final link?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => ref
                          .read(urlLauncherServiceProvider)
                          .launchExternal(link.url),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      // The ribbon's own icon, in gold on the navy button.
                      icon: ExcludeSemantics(
                        child: parishActivityIcon(
                          activity.kind,
                          color: AppColors.lightGold,
                          size: 22,
                        ),
                      ),
                      label: Text(link.label),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled detail line inside an expanded ribbon, e.g. "WHEN" above
/// "Every 2nd weekend". Wraps rather than truncating at large text sizes.
class _ActivityDetail extends StatelessWidget {
  const _ActivityDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 20, color: AppColors.gold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
