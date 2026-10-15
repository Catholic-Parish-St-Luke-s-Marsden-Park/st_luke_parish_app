import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Header for [AskLukeScreen]: title with a close button, subtitle, and an
/// "Online" status indicator.
class AskLukeHeader extends StatelessWidget {
  const AskLukeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 18),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      // The gradient fills the status bar area; only the content is inset.
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ask Luke',
                    style: AppTypography.display(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Ask Luke is pushed full-screen over the shell, so it needs
                // its own way back besides the system back gesture.
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.white,
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "St Luke's Parish Assistant · Always here to help",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
