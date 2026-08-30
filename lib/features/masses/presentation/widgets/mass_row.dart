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
  const MassRow({super.key, required this.massTime});

  final MassTime massTime;

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
              Text(
                massTime.time,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(massTime.name, style: textTheme.bodyLarge),
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
