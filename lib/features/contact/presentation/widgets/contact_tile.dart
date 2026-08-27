import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contact_item.dart';

/// A single tappable (or non-tappable, when [ContactItem.action] is
/// [ContactAction.none]) row rendering one [ContactItem]. Launches
/// `tel:`/`mailto:`/`https:` via the shared [UrlLauncherService] (same
/// injectable/testable pattern used in 02-parish-tab).
class ContactTile extends ConsumerWidget {
  const ContactTile({super.key, required this.item});

  final ContactItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActionable =
        item.action != ContactAction.none && item.actionTarget != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActionable
            ? () => ref
                  .read(urlLauncherServiceProvider)
                  .launchExternal(item.actionTarget!)
            : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(item.icon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
