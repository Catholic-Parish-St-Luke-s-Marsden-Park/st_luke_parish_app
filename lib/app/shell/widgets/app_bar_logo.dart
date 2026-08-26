import 'package:flutter/material.dart';

/// St Luke's Marsden Park wordmark logo shown in the shared [AppShell]
/// `AppBar`, bundled as a local asset (never hotlinked).
class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  static const String assetPath =
      'assets/images/branding/st_lukes_wordmark.jpg';

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, height: 30, fit: BoxFit.contain);
  }
}
