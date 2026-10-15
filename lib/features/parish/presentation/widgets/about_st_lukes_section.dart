import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_label.dart';

/// "About St Luke's" section: a pull-down card headed by the St Luke's emblem and
/// the title, showing the first paragraph as a teaser and the rest when
/// opened (parish request, 2026-10-15; supersedes REQ-F02-010's no-icon
/// rule).
class AboutStLukesSection extends StatelessWidget {
  const AboutStLukesSection({super.key});

  /// The cross-and-leaf emblem cut from the St Luke's wordmark logo.
  static const emblemAsset = 'assets/images/branding/st_lukes_emblem.png';

  /// Body copy supplied by the parish, one entry per paragraph.
  static const paragraphs = [
    "St Luke's, located in Marsden Park, Western Sydney, is proud to be "
        "Australia's newest Catholic Parish within the Diocese of "
        'Parramatta.',
    'The community was formed on January 1, 2018, when Deacon Tony Hoban '
        'was appointed as Pastoral Director. With the support of his wife, '
        'Annette, and a dedicated Advisory Group, they began shaping a '
        'community focused on faith, discipleship, and partnership with '
        "St Luke's Catholic College.",
    'In 2025, Fr Gayan Thamel was appointed as the first parish priest, '
        'marking a significant milestone in the life of the community. '
        "Under his leadership, St Luke's continues to grow as a welcoming "
        'and supportive Parish community.',
    "Masses were once held inside St Luke's College, but with the "
        'dedication of our parish community and support from the Diocese '
        'of Parramatta and the NSW Government, our new parish building was '
        'made possible – opened and blessed on the Feast of St Luke in '
        'October 2025. Masses and parish events are now held in our new, '
        "purpose-built St Luke's Catholic Parish building, located at the "
        'corner of Frontier Avenue and Northbourne Drive. Convenient car '
        'parking is available via Frontier Avenue, Marsden Park.',
    'We invite everyone seeking to grow in faith and belong to a welcoming '
        'community to join us.',
  ];

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.65,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel("Our Story"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: AppShapes.cardBorderRadius,
            boxShadow: AppShapes.cardShadow,
          ),
          // The card colour lives on a Material so the tile's tap ripple
          // shows.
          child: Material(
            color: AppColors.surfaceWhite,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: AppShapes.cardBorderRadius,
              side: const BorderSide(color: AppColors.border),
            ),
            child: Theme(
              // Drops ExpansionTile's top/bottom divider lines.
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                leading: ExcludeSemantics(
                  child: Image.asset(emblemAsset, width: 48, height: 48),
                ),
                title: Text(
                  "About St Luke's",
                  style: AppTypography.display(fontSize: 17),
                ),
                // The first paragraph is always visible as a teaser; the
                // rest pulls down.
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(paragraphs.first, style: bodyStyle),
                ),
                iconColor: AppColors.gold,
                collapsedIconColor: AppColors.primaryNavy,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final paragraph in paragraphs.skip(1)) ...[
                    const SizedBox(height: 10),
                    Text(paragraph, style: bodyStyle),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
