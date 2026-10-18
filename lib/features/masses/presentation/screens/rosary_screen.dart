import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/rosary_mysteries_config.dart';
import '../../domain/entities/rosary_mystery.dart';
import '../widgets/how_to_pray_rosary_card.dart';

/// "The Rosary", opened from the Holy Rosary ribbon (parish request,
/// 2026-10-18): How to Pray the Rosary, then the Mysteries with today's set
/// first and open and the others as pull-downs, each mystery with its
/// picture, Scripture and fruit.
class RosaryScreen extends StatelessWidget {
  const RosaryScreen({super.key, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final today = _now();
    final todaysSet = mysterySetForDay(rosaryMysterySets, today);
    // Today's set first, then the rest in the card's order.
    final sets = [
      ?todaysSet,
      for (final set in rosaryMysterySets)
        if (set != todaysSet) set,
    ];
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('The Rosary')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Learn how to pray the Rosary, then choose a set of Mysteries '
              'to meditate on while you pray each decade. Today is '
              '${_weekdayNames[today.weekday - 1]}.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          HowToPrayRosaryCard(todaysMysteries: todaysSet?.name),
          for (final set in sets)
            _MysterySetCard(set: set, isToday: set == todaysSet),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rosaryMysteriesSeasonNote, style: textTheme.bodySmall),
                const SizedBox(height: 10),
                Text(rosaryMysteriesSource, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The card's own colour for each set, used as an accent stripe.
Color _accent(RosaryMysteryKind kind) => switch (kind) {
  RosaryMysteryKind.joyful => const Color(0xFFF2C230),
  RosaryMysteryKind.luminous => const Color(0xFFF08A24),
  RosaryMysteryKind.sorrowful => const Color(0xFFD93A3A),
  RosaryMysteryKind.glorious => const Color(0xFF3FA9E0),
};

/// One set of Mysteries as a pull-down card with a coloured stripe; open by
/// default when it is today's set.
class _MysterySetCard extends StatelessWidget {
  const _MysterySetCard({required this.set, required this.isToday});

  final RosaryMysterySet set;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      child: Material(
        color: AppColors.surfaceWhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _accent(set.kind), width: 8),
            ),
          ),
          child: Theme(
            // Drops ExpansionTile's divider lines inside the card.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isToday,
              tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.primaryNavy,
              title: Text(
                set.name,
                style: AppTypography.display(
                  fontSize: 19,
                  color: AppColors.primaryNavy,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(set.daysLabel, style: textTheme.bodySmall),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "Today's Mysteries",
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              children: [
                for (final (i, mystery) in set.mysteries.indexed) ...[
                  if (i > 0) const Divider(height: 24, color: AppColors.border),
                  _MysteryEntry(
                    number: i + 1,
                    adjective: set.adjective,
                    mystery: mystery,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One mystery: "1st Joyful Mystery", its title, the Scripture verse and
/// reference, and the fruit of the mystery.
class _MysteryEntry extends StatelessWidget {
  const _MysteryEntry({
    required this.number,
    required this.adjective,
    required this.mystery,
  });

  final int number;
  final String adjective;
  final RosaryMystery mystery;

  static const _ordinals = ['1st', '2nd', '3rd', '4th', '5th'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // The mystery's picture from the Rosary card.
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    mystery.imageAsset,
                    width: 84,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // e.g. "1st Glorious Mystery (1st Decade)".
                    Text(
                      '${_ordinals[number - 1]} $adjective Mystery '
                              '(${_ordinals[number - 1]} Decade)'
                          .toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.darkGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mystery.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNavy,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            mystery.verse,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 2),
          Text(mystery.reference, style: textTheme.bodySmall),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Fruit of the Mystery: '),
                TextSpan(
                  text: mystery.fruit,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
