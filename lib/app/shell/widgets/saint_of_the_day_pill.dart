import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/saint_of_the_day/presentation/screens/saint_of_the_day_screen.dart';
import '../../../shared/widgets/app_pill_button.dart';

/// AppBar pill that performs a full-screen navigation to
/// [SaintOfTheDayScreen] (REQ-F06-001) — the "Coming soon." placeholder
/// dialog has been removed. Rendered with a solid gold fill (REQ-F06-018),
/// matching this app's existing `filledButtonTheme` gold-button precedent,
/// so it reads as visually distinct from the translucent-white "Ask Luke"
/// pill beside it.
class SaintOfTheDayPill extends StatelessWidget {
  const SaintOfTheDayPill({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      label: 'Saint of the Day',
      icon: Icons.auto_awesome_rounded,
      backgroundColor: AppColors.gold,
      foregroundColor: AppColors.textPrimary,
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SaintOfTheDayScreen()));
      },
    );
  }
}
