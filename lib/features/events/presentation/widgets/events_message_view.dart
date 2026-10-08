import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/external_links.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared fully-empty/parsing-failure/network-failure treatment for the
/// Events section (REQ-F08-016, REQ-F08-018, REQ-F08-019): a user-friendly
/// [message] (no raw exception text), plus — only when [showWebsiteLink] is
/// true — a fallback link that opens `ExternalLinks.eventsPage` externally.
/// The empty-this-week case (REQ-F08-017) passes `showWebsiteLink: false`,
/// since `EventsSection` already renders its own "View all upcoming
/// events" in-app link below this view in that case, rather than sending
/// the user out to the website when later events do exist.
class EventsMessageView extends ConsumerWidget {
  const EventsMessageView({
    super.key,
    required this.message,
    this.showWebsiteLink = true,
  });

  final String message;
  final bool showWebsiteLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: textTheme.bodyMedium),
          if (showWebsiteLink) ...[
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref
                    .read(urlLauncherServiceProvider)
                    .launchExternal(ExternalLinks.eventsPage),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'View upcoming events on the parish website ↗',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
