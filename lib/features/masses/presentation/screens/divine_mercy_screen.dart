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
  const DivineMercyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Divine Mercy Chaplet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
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
                // The red and pale rays of the Divine Mercy image.
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFC8102E), width: 8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Pray the Chaplet',
                          style: AppTypography.display(
                            fontSize: 19,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jesus, I trust in You',
                        style: textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // The Divine Mercy image, as painted under St
                      // Faustina's direction.
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
                      const SizedBox(height: 12),
                      PrayerBeadsStepper(steps: divineMercySteps),
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
