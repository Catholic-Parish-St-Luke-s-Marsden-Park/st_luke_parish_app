import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the Masses & events destination. Real Mass times and
/// event data will be added in a later feature slice.
class MassesScreen extends StatelessWidget {
  const MassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Masses & Events',
      icon: Icons.calendar_month_rounded,
    );
  }
}
