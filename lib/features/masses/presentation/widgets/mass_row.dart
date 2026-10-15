import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
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
  const MassRow({
    super.key,
    required this.massTime,
    this.highlightTimes = false,
  });

  final MassTime massTime;

  /// Show each time in a gold oval (like the Saint of the Day pill) instead
  /// of as "Label: time" text. Decoration only; nothing is tappable.
  final bool highlightTimes;

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
            runSpacing: 8,
            children: [
              if (highlightTimes) ...[
                if (massTime.label case final day?)
                  // A minimum (not fixed) width lines the ovals up under
                  // each other, but still grows with large system text.
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 104),
                    child: Text(
                      day,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                for (final time in massTime.allTimes) _TimePill(time),
              ] else
                Text(
                  massTime.label == null
                      ? massTime.time
                      : '${massTime.label}: ${massTime.time}',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (massTime.name != null)
                Text(massTime.name!, style: textTheme.bodyLarge),
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

/// A time in a gold oval, styled like the Saint of the Day pill. Not a
/// button: there is no tap behaviour.
class _TimePill extends StatelessWidget {
  const _TimePill(this.time);

  final String time;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: AppShapes.pillBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          time,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
