import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/divine_mercy_config.dart';
import '../widgets/how_to_pray_rosary_card.dart';

/// The Chaplet of Divine Mercy, opened from the side menu: the same
/// bead-by-bead guide as The Rosary, one prayer per tap of Next (parish
/// request, 2026-10-18).
class DivineMercyScreen extends ConsumerWidget {
  const DivineMercyScreen({super.key, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// The red of the Divine Mercy image's rays.
  static const _mercyRed = Color(0xFFC8102E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Divine Mercy Chaplet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The Divine Mercy image, as painted under St Faustina's
                // direction.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        divineMercyImage,
                        semanticLabel:
                            'The Divine Mercy image: Jesus with red and '
                            'pale rays shining from His Heart',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  divineMercyImageCaption,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  divineMercyIntro,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
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
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: _mercyRed, width: 8)),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  // Closed until tapped, like Pray the Rosary (parish
                  // request, 2026-10-19).
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    tilePadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    iconColor: AppColors.gold,
                    collapsedIconColor: AppColors.primaryNavy,
                    // A small Divine Mercy image on the card itself.
                    leading: ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          divineMercyImage,
                          width: 48,
                          height: 56,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.6),
                        ),
                      ),
                    ),
                    title: Text(
                      'Pray the Chaplet',
                      style: AppTypography.display(
                        fontSize: 19,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Jesus, I trust in You',
                        style: textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    children: [
                      PrayerBeadsStepper(
                        steps: divineMercySteps,
                        centreImage: divineMercyImage,
                        progressKey: 'divine_mercy_chaplet',
                        today: _now(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(divineMercySource, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => ref
                      .read(urlLauncherServiceProvider)
                      .launchExternal(divineMercyPageUrl),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('More prayers at thedivinemercy.org'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
