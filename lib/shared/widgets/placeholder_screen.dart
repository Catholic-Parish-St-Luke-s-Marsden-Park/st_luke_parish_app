import 'package:flutter/material.dart';

import '../../core/layout/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Minimal stub content shared by every nav-destination placeholder screen
/// in this bootstrap slice. Real feature content will replace this once
/// each destination's data/domain layers are built.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          child: Padding(
            padding: Responsive.pagePadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: AppColors.primaryNavy),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.display(fontSize: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
