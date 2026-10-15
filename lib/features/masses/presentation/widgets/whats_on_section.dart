import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mass_times_card.dart';
import 'mass_card.dart';
import 'mass_row.dart';
import 'mass_section_header.dart';
import 'mass_sub_group_label.dart';

/// Section 1 — "What's On": one always-open card per [MassTimesCard]
/// ("Weekend Mass Times", then "Weekday Mass Times"), each headed by its
/// title. Sub-group labels show only when a card holds more than one
/// group, since a lone "Weekday" label would repeat the card title.
class WhatsOnSection extends StatelessWidget {
  const WhatsOnSection({super.key, required this.cards});

  final List<MassTimesCard> cards;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MassSectionHeader("What's On"),
        for (final card in cards)
          MassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Semantics(
                    header: true,
                    child: Text(
                      card.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                for (final subGroup in card.subGroups) ...[
                  if (card.subGroups.length > 1)
                    MassSubGroupLabel(subGroup.label),
                  for (final row in subGroup.rows)
                    MassRow(massTime: row, highlightTimes: card.highlightTimes),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
