import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the Ministries destination. Real ministry listing/detail
/// content will be added in a later feature slice.
class MinistriesScreen extends StatelessWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Ministries',
      icon: Icons.groups_rounded,
    );
  }
}
