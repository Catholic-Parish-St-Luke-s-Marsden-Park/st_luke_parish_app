import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the Donate destination. The real donate flow (webview
/// integration) is explicitly out of scope for this bootstrap slice.
class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Donate',
      icon: Icons.favorite_rounded,
    );
  }
}
