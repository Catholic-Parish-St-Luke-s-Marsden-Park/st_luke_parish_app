import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/announcement.dart';

/// A single, plain, non-interactive "Parish News" row: badge/category text,
/// title, body, and date (REQ-F05-023). No icon/emoji (REQ-F05-030).
class AnnouncementListItem extends StatelessWidget {
  const AnnouncementListItem({
    super.key,
    required this.announcement,
    this.isLast = false,
  });

  final Announcement announcement;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.badge.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 4),
          Text(announcement.title, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(announcement.body, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(announcement.date, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
