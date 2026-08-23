import 'package:flutter/material.dart';

import '../../../../shared/widgets/placeholder_screen.dart';

/// Placeholder for the News & Bulletins destination. Real bulletin scraping
/// and parsing will be added in a later feature slice.
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'News & Bulletins',
      icon: Icons.article_rounded,
    );
  }
}
