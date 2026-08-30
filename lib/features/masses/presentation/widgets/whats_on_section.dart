import 'package:flutter/material.dart';

import '../../domain/entities/mass_sub_group.dart';
import 'mass_card.dart';
import 'mass_row.dart';
import 'mass_section_header.dart';
import 'mass_sub_group_label.dart';

/// Section 1 — "What's On": a single card containing three labeled
/// sub-groups (Sunday / Saturday Vigil / Weekday), in order
/// (REQ-F04-003..008).
class WhatsOnSection extends StatelessWidget {
  const WhatsOnSection({super.key, required this.subGroups});

  final List<MassSubGroup> subGroups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MassSectionHeader("What's On"),
        MassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final subGroup in subGroups) ...[
                MassSubGroupLabel(subGroup.label),
                for (final row in subGroup.rows) MassRow(massTime: row),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
