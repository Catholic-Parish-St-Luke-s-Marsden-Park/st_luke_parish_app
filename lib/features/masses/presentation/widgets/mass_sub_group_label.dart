import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Small, uppercase sub-group label used inside the "What's On" card
/// ("Sunday" / "Saturday Vigil" / "Weekday") — visually smaller and muted
/// compared to [MassSectionHeader]'s top-level section titles.
class MassSubGroupLabel extends StatelessWidget {
  const MassSubGroupLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
