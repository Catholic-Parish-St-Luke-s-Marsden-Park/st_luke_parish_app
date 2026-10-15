import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mass_time.dart';
import 'mass_row.dart';

/// Several day-and-time Masses on one line to save space, e.g.
/// "Wednesday 7:30 AM · Thursday 9:00 AM" (parish request, 2026-10-16).
///
/// Each day stays with its time; with large system text the pairs wrap
/// onto further lines instead of overflowing.
class MassDaysRow extends StatelessWidget {
  const MassDaysRow({super.key, required this.massTimes});

  final List<MassTime> massTimes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          for (final (i, massTime) in massTimes.indexed) ...[
            if (i > 0)
              const ExcludeSemantics(
                child: Text(
                  '·',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: MassRow.timeFontSize,
                  ),
                ),
              ),
            // An inner Wrap keeps each day with its time, yet lets a pair
            // too wide for the card (very large system text) wrap rather
            // than overflow.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  massTime.label!,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    fontSize: 16,
                  ),
                ),
                Text(
                  massTime.time,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    fontSize: MassRow.timeFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
