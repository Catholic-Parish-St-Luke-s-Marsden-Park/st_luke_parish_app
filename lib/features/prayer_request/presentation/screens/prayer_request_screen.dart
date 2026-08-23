import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the drawer's Prayer Request destination. Real webview
/// integration is explicitly out of scope for this bootstrap slice.
class PrayerRequestScreen extends StatelessWidget {
  const PrayerRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Request')),
      body: const PlaceholderScreen(
        title: 'Prayer Request',
        icon: Icons.favorite_border_rounded,
      ),
    );
  }
}
