import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Small uppercase section header above each ministry category's grid,
/// e.g. "LITURGY & WORSHIP".
class MinistryCategoryHeader extends StatelessWidget {
  const MinistryCategoryHeader(this.category, {super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
