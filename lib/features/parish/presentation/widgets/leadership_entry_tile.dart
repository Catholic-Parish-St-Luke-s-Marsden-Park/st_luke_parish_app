import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/church_leadership_entry.dart';

/// A single tappable (or non-tappable, if [ChurchLeadershipEntry.linkUrl]
/// is `null`) row showing a leadership/diocese entry's image, name and
/// role. Tapping launches [ChurchLeadershipEntry.linkUrl] in the device's
/// external browser via [urlLauncherServiceProvider].
class LeadershipEntryTile extends ConsumerWidget {
  const LeadershipEntryTile({super.key, required this.entry});

  final ChurchLeadershipEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkUrl = entry.linkUrl;
    final isTappable = linkUrl != null;

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
