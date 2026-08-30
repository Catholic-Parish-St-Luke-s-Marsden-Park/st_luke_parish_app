import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/external_links.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared empty-result / parsing-failure / network-failure treatment for
/// the bulletins section: a user-friendly [message] (no raw exception text
/// — REQ-F05-018/019/020) plus a "View bulletins on the parish website"
/// fallback link that opens `ExternalLinks.bulletinsArchive` externally via
/// the shared [UrlLauncherService] (REQ-F05-022).
class BulletinsMessageView extends ConsumerWidget {
  const BulletinsMessageView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ref
                  .read(urlLauncherServiceProvider)
                  .launchExternal(ExternalLinks.bulletinsArchive),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                alignment: Alignment.centerLeft,
                child: Text(
                  'View bulletins on the parish website ↗',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
