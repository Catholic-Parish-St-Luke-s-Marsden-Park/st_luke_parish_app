import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/static_ministries_config.dart';
import '../../domain/entities/ministry.dart';
import '../widgets/ministry_card.dart';
import '../widgets/ministry_category_header.dart';
import 'ministry_detail_screen.dart';

/// Ministries destination: a header, then a grid of ministry cards grouped
/// under each of the 4 categories (all 16 ministries reachable). Content is
/// static in-code config, not fetched/scraped.
class MinistriesScreen extends StatelessWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ministries & Groups',
                style: AppTypography.display(
                  fontSize: 22,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our pastoral plan: Faith Enrichment · Serving God & Others · '
                'Community Connection · Vibrant Worship',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        for (final category in ministryCategories) ...[
          MinistryCategoryHeader(category),
          _MinistryGrid(
            ministries: staticMinistries
                .where((m) => m.category == category)
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _MinistryGrid extends StatelessWidget {
  const _MinistryGrid({required this.ministries});

  final List<Ministry> ministries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ministries.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final ministry = ministries[index];
          return MinistryCard(
            ministry: ministry,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MinistryDetailScreen(ministryId: ministry.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
