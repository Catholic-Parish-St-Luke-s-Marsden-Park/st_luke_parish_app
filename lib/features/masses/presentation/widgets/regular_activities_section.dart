import 'package:flutter/material.dart';

import '../../domain/entities/parish_activity.dart';
import 'activity_ribbon.dart';
import 'mass_section_header.dart';

/// Section 2 — "Regular Activities" (formerly "Reconciliation &
/// Sacraments"): one collapsible [ActivityRibbon] per activity, in order.
/// All ribbons start collapsed.
class RegularActivitiesSection extends StatelessWidget {
  const RegularActivitiesSection({super.key, required this.activities});

  final List<ParishActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MassSectionHeader('Regular Parish Activities'),
        for (final activity in activities) ActivityRibbon(activity: activity),
      ],
    );
  }
}
