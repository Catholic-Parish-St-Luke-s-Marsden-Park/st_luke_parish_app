import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/saint_of_the_day.dart';

/// Screen header: date pill + saint name + feast day, matching the
/// reference implementation's content hierarchy without its emoji/icon
/// usage (REQ-F06-013).
class SaintOfTheDayHeader extends StatelessWidget {
  const SaintOfTheDayHeader({super.key, required this.saint});

  final SaintOfTheDay saint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              saint.displayDate.toUpperCase(),
              style: AppTypography.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            saint.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          if (saint.feast.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              saint.feast,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
