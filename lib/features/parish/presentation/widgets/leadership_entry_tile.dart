import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/church_leadership_entry.dart';

/// A single row showing a leadership/diocese entry's image, name and role.
///
/// With [ChurchLeadershipEntry.about] set (the Pope and the Bishop), the row
/// pulls down to show a short introduction and a button to
/// [ChurchLeadershipEntry.linkUrl]. Otherwise tapping launches the link (if
/// any) in the device's external browser via [urlLauncherServiceProvider].
class LeadershipEntryTile extends ConsumerWidget {
  const LeadershipEntryTile({super.key, required this.entry});

  final ChurchLeadershipEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkUrl = entry.linkUrl;
    final isTappable = linkUrl != null;

    if (entry.about != null) return _PullDownEntry(entry: entry);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTappable
            ? () => ref.read(urlLauncherServiceProvider).launchExternal(linkUrl)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleGold,
                backgroundImage: AssetImage(entry.assetPath),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTappable)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Pope's and Bishop's rows: photo, name and role, pulling down to a
/// short introduction, a website button and the photo credit.
class _PullDownEntry extends ConsumerWidget {
  const _PullDownEntry({required this.entry});

  final ChurchLeadershipEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final linkUrl = entry.linkUrl;

    return Material(
      type: MaterialType.transparency,
      child: Theme(
        // Drops ExpansionTile's divider lines inside the card.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.textMuted,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.paleGold,
            backgroundImage: AssetImage(entry.assetPath),
          ),
          title: Text(
            entry.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            entry.role,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          children: [
            Text(
              entry.about!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (linkUrl != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref
                    .read(urlLauncherServiceProvider)
                    .launchExternal(linkUrl),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(entry.linkLabel ?? 'Visit website'),
              ),
            ],
            if (entry.photoCredit case final credit?) ...[
              const SizedBox(height: 8),
              Text(credit, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
