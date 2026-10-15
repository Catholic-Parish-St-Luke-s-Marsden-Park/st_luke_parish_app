import 'package:flutter/material.dart';

import '../../domain/entities/mass_times_card.dart';
import 'mass_card.dart';
import 'mass_times_card_icon.dart';
import 'mass_row.dart';
import 'mass_section_header.dart';
import 'mass_sub_group_label.dart';

/// Section 1 — "What's On": one always-open [MassCard] per
/// [MassTimesCard] (Saturday Vigil Mass, Sunday Mass Times, Weekday Mass
/// Times), each with a navy title band. Sub-group labels show only when a
/// card holds more than one group, since a lone label would repeat the
/// card title.
class WhatsOnSection extends StatelessWidget {
  const WhatsOnSection({super.key, required this.cards});

  final List<MassTimesCard> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MassSectionHeader("What's On"),
        for (final card in cards)
          MassCard(
            title: card.title,
            icon: switch (card.kind) {
              final kind? => massTimesCardIcon(kind),
              null => null,
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final subGroup in card.subGroups) ...[
                  if (card.subGroups.length > 1)
                    MassSubGroupLabel(subGroup.label),
                  for (final row in subGroup.rows)
                    MassRow(massTime: row, listTimes: card.listTimes),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
