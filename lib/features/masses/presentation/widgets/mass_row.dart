import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mass_time.dart';

/// A single, plain-text, non-interactive row rendering one [MassTime]'s
/// `time` + `name` + optional `note` (REQ-F04-012: no icon, no tap
/// affordance anywhere on this screen).
///
/// `time` and `name` are laid out with [Wrap] rather than a fixed-width
/// row/column so long strings (e.g. "By enrolment") and increased system
/// text scale reflow instead of overflowing (CLAUDE.md accessibility
/// rules; REQ-F04-020).
class MassRow extends StatelessWidget {
  const MassRow({super.key, required this.massTime, this.listTimes = false});

  final MassTime massTime;

  /// Lay out the day (if any) and each time as separate text, e.g.
  /// "Wednesday   7:30 AM" or "8:00 AM · 10:00 AM · 5:30 PM", rather than
  /// "Day: time".
  final bool listTimes;

  /// Mass times are the main thing people look for, so they are set larger
  /// than the surrounding text (parish request, 2026-10-16).
  static const double _timeFontSize = 19;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 2,
            children: [
              if (listTimes) ...[
                if (massTime.label case final day?)
                  // A minimum (not fixed) width lines the times up under
                  // each other, but still grows with large system text.
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 104),
                    child: Text(
                      day,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                      ),
                    ),
                  ),
                for (final (i, time) in massTime.allTimes.indexed) ...[
                  if (i > 0)
                    const ExcludeSemantics(
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: _timeFontSize,
                        ),
                      ),
                    ),
                  Text(
                    time,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryNavy,
                      fontSize: _timeFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ] else
                Text(
                  massTime.label == null
                      ? massTime.time
                      : '${massTime.label}: ${massTime.time}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    fontSize: _timeFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (massTime.name != null)
                Text(
                  massTime.name!,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryNavy,
                  ),
                ),
            ],
          ),
          if (massTime.note != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(massTime.note!, style: textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
