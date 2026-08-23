import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the drawer's Resources destination. Real resource links
/// will be added in a later feature slice.
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: const PlaceholderScreen(
        title: 'Resources',
        icon: Icons.menu_book_rounded,
      ),
    );
  }
}
