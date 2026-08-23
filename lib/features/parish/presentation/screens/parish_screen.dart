import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the Parish home destination. Real content (welcome,
/// clergy, parish overview) will be added in a later feature slice.
class ParishScreen extends StatelessWidget {
  const ParishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Parish', icon: Icons.church_rounded);
  }
}
