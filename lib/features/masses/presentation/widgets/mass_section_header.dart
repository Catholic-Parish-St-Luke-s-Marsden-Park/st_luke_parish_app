import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Top-level section title ("What's On" / "Reconciliation & Sacraments").
/// Kept local to the Masses feature rather than reusing the Parish tab's
/// `SectionLabel`, to keep feature concerns isolated per root `CLAUDE.md`
/// (matching the precedent set by Ministries' own
/// `MinistryCategoryHeader`).
///
/// Intentionally styled larger/darker than [MassSubGroupLabel] so the two
/// label levels stay visually distinguishable (REQ-F04-004's requirement
/// that sub-group labels differ from the two top-level section titles).
class MassSectionHeader extends StatelessWidget {
  const MassSectionHeader(this.label, {super.key});

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
