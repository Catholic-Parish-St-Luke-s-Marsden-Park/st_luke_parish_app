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
                // 12 is the project's documented floor for hardcoded
                // sizes; this was 11. textPrimary on the gold pill
                // measures 6.95:1, comfortably past AA.
                fontSize: 12,
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
                // heroGradient runs navy -> lightBlue, and the feast line
                // sits at the bottom of the header where it wraps into
                // the lighter end. At alpha 0.75 that measured 3.76:1
                // against lightBlue #3A6BB5 — under the 4.5:1 AA floor.
                // 0.92 measures 4.77:1 and matches the emphasized section
                // card's body treatment.
                color: Colors.white.withValues(alpha: 0.92),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
