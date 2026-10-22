import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/parish_name_lockup.dart';

/// Hero banner for the Parish tab: the parish name set out as in the side
/// menu header (parish request, 2026-10-22) + subtext, no eyebrow label
/// (REQ-F02-002) and no old "Australia's newest catholic parish" copy.
class ParishHeroBanner extends StatelessWidget {
  const ParishHeroBanner({super.key});

  static const String subtitle =
      "We are continually attracting people to St Luke's and everyone who "
      'engages as a member of our community is transformed in every area of '
      'their life by having a deeper relationship with Jesus.';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            label: "St Luke's Catholic Parish, Marsden Park",
            child: const ExcludeSemantics(
              child: ParishNameLockup(nameSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
