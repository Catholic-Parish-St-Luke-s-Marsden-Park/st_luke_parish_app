import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/parish_notice_provider.dart';
import 'announcement_dialog.dart';

/// A floating megaphone button, shown only while the parish website's home
/// page has a pop-up announcement; tapping it opens that announcement
/// (parish request, 2026-10-16). Nothing is shown otherwise.
class AnnouncementButton extends ConsumerWidget {
  const AnnouncementButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(currentParishNoticeProvider).value;
    if (notice == null) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () => showAnnouncementDialog(context, notice),
      tooltip: 'Special announcement',
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.primaryNavy,
      child: const Icon(Icons.campaign_rounded, size: 28),
    );
  }
}
