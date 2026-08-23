import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the Contact & Map destination. Real parish office/
/// contact details will be added in a later feature slice.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Contact & Map',
      icon: Icons.location_on_rounded,
    );
  }
}
