import 'package:flutter/material.dart';

import '../../data/config/static_announcements_config.dart';
import 'announcement_list_item.dart';
import 'news_card.dart';
import 'news_section_header.dart';

/// "Parish News" section: exactly 2 static announcement entries
/// (REQ-F05-023..025).
class ParishNewsSection extends StatelessWidget {
  const ParishNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewsSectionHeader('Parish News'),
        NewsCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < staticAnnouncements.length; i++)
                  AnnouncementListItem(
                    announcement: staticAnnouncements[i],
                    isLast: i == staticAnnouncements.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
