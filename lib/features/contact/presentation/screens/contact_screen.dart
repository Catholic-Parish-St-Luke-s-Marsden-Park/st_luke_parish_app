import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cta_pill_button.dart';
import '../../data/config/static_contact_config.dart';
import '../widgets/contact_tile.dart';

/// Contact destination: header, a static tappable "map preview" card and
/// "Open in Google Maps" button (both hand off to the external Google Maps
/// app/browser — no embedded interactive map SDK), then the 8 static
/// contact tiles.
class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  static const String _mapsUrl = 'https://maps.google.com/?q=$parishMapsQuery';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openMaps() =>
        ref.read(urlLauncherServiceProvider).launchExternal(_mapsUrl);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact & Location',
                style: AppTypography.display(
                  fontSize: 22,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our doors are open. Come as you are.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: InkWell(
            borderRadius: AppShapes.cardBorderRadius,
            onTap: openMaps,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: AppShapes.cardBorderRadius,
                border: Border.all(color: AppColors.border),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cream, Color(0xFFEDEAE0)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 36,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    parishAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to view on the map',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: CtaPillButton(
            label: 'Open in Google Maps',
            icon: Icons.map_rounded,
            onPressed: openMaps,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in staticContactItems) ContactTile(item: item),
      ],
    );
  }
}
