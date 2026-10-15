import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import 'section_label.dart';

/// "Our Parish Prayer" section at the bottom of the Parish tab: the parish
/// prayer and its closing invocations on a navy card, matching the parish's
/// web app (parish request, 2026-10-15).
class ParishPrayerSection extends StatelessWidget {
  const ParishPrayerSection({super.key});

  static const prayer =
      'O God, You show us in St Luke, our patron, a person of faith who '
      'desired all people to come to know and love You in the community of '
      'Your Church. Teach us to embrace what St Luke pioneered: discipleship '
      'of Jesus Christ. Trusting in your love and grace and nourished by Word '
      'and Sacrament may we grow in our relationship with you and together '
      'make our Catholic Parish Community a community of communities, a '
      'sanctuary where the thirsty come to drink in the midst of their '
      'journey, and a centre of constant missionary outreach. We ask this '
      'through Christ our Lord. Amen.';

  static const invocations = [
    'St Luke, pray for us.',
    'St Mary of the Cross MacKillop, pray for us.',
    'Mary, Mother of God, pray for us.',
    'All saints and Martyrs, pray for us.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Our Parish Prayer'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            // Navy to mid-blue (not the lighter hero gradient) so the white
            // and gold text keep WCAG AA contrast across the whole card.
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryNavy, AppColors.midBlue],
            ),
            borderRadius: AppShapes.cardBorderRadius,
            boxShadow: AppShapes.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Text(
                      '✦',
                      style: TextStyle(color: AppColors.lightGold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PARISH PRAYER',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                prayer,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 14),
              for (final invocation in invocations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    invocation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
