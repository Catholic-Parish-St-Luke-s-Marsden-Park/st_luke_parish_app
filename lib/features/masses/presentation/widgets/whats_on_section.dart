import 'package:flutter/material.dart';

import '../../domain/entities/mass_times_card.dart';
import 'mass_card.dart';
import 'mass_times_card_icon.dart';
import 'mass_row.dart';
import 'mass_sub_group_label.dart';

/// Section 1 — the Mass times (no section title): one always-open [MassCard] per
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
        // No section title: the cards' own navy headers say what they are
        // (parish request, 2026-10-15).
        const SizedBox(height: 12),
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
