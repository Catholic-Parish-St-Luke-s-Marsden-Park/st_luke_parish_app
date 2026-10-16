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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Image.asset(assetPath, height: 26, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
