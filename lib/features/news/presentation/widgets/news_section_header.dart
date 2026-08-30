import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Top-level section title ("Latest Bulletins" / "Parish News" / "Submit a
/// Prayer Request" — REQ-F05-031). Kept local to the News feature rather
/// than reusing another feature's section-label widget, matching the
/// feature-isolation precedent set by `MassSectionHeader`.
class NewsSectionHeader extends StatelessWidget {
  const NewsSectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.primaryNavy),
      ),
    );
  }
}
