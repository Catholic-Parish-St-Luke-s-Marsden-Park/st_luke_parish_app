import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/external_links.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cta_pill_button.dart';
import '../../data/config/prayer_intentions_config.dart';
import 'news_card.dart';
import 'news_section_header.dart';

/// "Submit a Prayer Request" section: a static quote + body + CTA button
/// that opens `ExternalLinks.prayerRequests` externally via the shared
/// [UrlLauncherService] (REQ-F05-026..029). No icon/emoji (REQ-F05-027).
class PrayerIntentionsSection extends ConsumerWidget {
  const PrayerIntentionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewsSectionHeader('Submit a Prayer Request'),
        NewsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${PrayerIntentionsConfig.quote}"',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              Text(PrayerIntentionsConfig.body, style: textTheme.bodyMedium),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child: CtaPillButton(
                  label: 'Submit Prayer Request ↗',
                  onPressed: () => ref
                      .read(urlLauncherServiceProvider)
                      .launchExternal(ExternalLinks.prayerRequests),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
