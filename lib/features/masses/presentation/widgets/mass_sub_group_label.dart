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
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.darkGold,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
