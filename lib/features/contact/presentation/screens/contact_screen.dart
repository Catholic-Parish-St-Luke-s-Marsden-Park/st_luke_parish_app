import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/webview/simple_webview_screen.dart';
import '../../../../shared/widgets/cta_pill_button.dart';
import '../../data/config/static_contact_config.dart';
import '../widgets/contact_tile.dart';

/// Contact destination: header, an embedded Google Maps preview, an "Open
/// in Google Maps" button, then the 8 static contact tiles.
///
/// The map preview reuses the same `output=embed` page the parish PWA
/// embeds in an iframe (`https://maps.google.com/maps?q=...&output=embed`
/// -- no API key required), rendered here through the shared in-app
/// [SimpleWebViewScreen], the same mechanism already used for the Donate
/// tab. Like the PWA's own `.map-wrap` (`pointer-events: none`), it's
/// wrapped in [IgnorePointer]: a live visual preview only, not a pannable
/// widget -- tapping anywhere on it (or the pill below) hands off to the
/// real, fully-interactive Google Maps app/browser via
/// [UrlLauncherService]. This also sidesteps the WebView capturing pan
/// gestures that `ListView` needs for scrolling.
class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  static const String _mapsUrl = 'https://maps.google.com/?q=$parishMapsQuery';

  // The Google Maps Embed endpoint (`output=embed`) only renders when the
  // request genuinely comes from inside an <iframe> -- loaded directly as
  // a WebView's own page, Google's server refuses it with "The Google Maps
  // Embed API must be used in an iframe." instead. This wrapper document,
  // loaded via SimpleWebViewScreen's `html` (loadHtmlString), nests the
  // embed URL in a real <iframe>, exactly mirroring the PWA's own
  // `.map-wrap` markup/CSS (stlukes-marsden-park-app/index.html).
  static const String _mapEmbedHtml =
      '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body { margin: 0; padding: 0; height: 100%; }
iframe { width: 100%; height: 100%; border: 0; display: block; }
</style>
</head>
<body>
<iframe
  src="https://maps.google.com/maps?q=$parishMapsQuery&output=embed"
  allowfullscreen
  loading="lazy"
  referrerpolicy="no-referrer-when-downgrade"></iframe>
</body>
</html>
''';

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
          child: GestureDetector(
            key: const Key('contactMapPreviewCard'),
            onTap: openMaps,
            child: Container(
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppShapes.cardBorderRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: const IgnorePointer(
                child: SimpleWebViewScreen(html: _mapEmbedHtml),
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
