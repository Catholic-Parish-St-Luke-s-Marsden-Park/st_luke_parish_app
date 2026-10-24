import 'package:flutter/material.dart';

import '../../../core/theme/app_shapes.dart';

/// St Luke's Marsden Park wordmark logo shown in the shared [AppShell]
/// `AppBar`, bundled as a local asset (never hotlinked).
///
/// The wordmark has a white background, so it sits on a white chip with the
/// same pill rounding as the "Saint of the Day" and "Ask Luke" buttons beside
/// it, instead of showing as a hard-cornered rectangle on the navy bar.
class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  /// Wordmark size inside the chip (the image is 2560x843, so 26dp tall is
  /// about 79dp wide) and the resulting chip width. [AppShell] reserves
  /// [chipWidth] so the buttons beside it can never squeeze the logo.
  static const double imageHeight = 26;
  static const double imageWidth = 79;
  static const double chipPadding = 10;
  static const double chipWidth = imageWidth + 2 * chipPadding;

  static const String assetPath =
      'assets/images/branding/st_lukes_wordmark.jpg';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "St Luke's Catholic Parish Marsden Park",
      image: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppShapes.pillBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: chipPadding,
              vertical: 4,
            ),
            child: Image.asset(
              assetPath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
