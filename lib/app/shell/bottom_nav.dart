import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Static configuration for the 6 bottom-navigation destinations.
class BottomNavDestination {
  const BottomNavDestination({
    required this.icon,
    required this.label,
    this.pulse = false,
    this.color,
  });

  final IconData icon;
  final String label;

  /// Whether this destination's icon should gently pulse to draw a little
  /// extra attention to it -- currently only the Donate tab, mirroring the
  /// `heartbeat` animation already on the parish PWA's own Donate nav icon
  /// (see [PulsingNavIcon]'s doc comment for the source of truth).
  final bool pulse;

  /// A fixed icon color that overrides the nav bar's normal
  /// selected/unselected theming -- currently only the Donate tab, set to
  /// [AppColors.gold] to match the parish PWA's Donate icon, which is
  /// always gold regardless of which tab is active (`.nav-btn.donate-btn`
  /// in `stlukes-marsden-park-app/index.html`). `null` (every other
  /// destination) means "use the shared nav bar theme as normal".
  ///
  /// The PWA also forces its Donate *label* text gold at all times, not
  /// just the icon -- `NavigationBar`'s theme only exposes one shared
  /// selected/unselected color rule for every destination's label, with
  /// no per-destination override, so this app's Donate label intentionally
  /// still follows the normal rule (gold when selected, muted otherwise)
  /// rather than forcing a bigger nav-bar rework for an always-gold label
  /// too.
  final Color? color;
}

const List<BottomNavDestination> bottomNavDestinations = [
  BottomNavDestination(icon: Icons.church_rounded, label: 'Parish'),
  BottomNavDestination(icon: Icons.calendar_month_rounded, label: 'Masses'),
  BottomNavDestination(icon: Icons.article_rounded, label: 'News'),
  BottomNavDestination(icon: Icons.groups_rounded, label: 'Ministries'),
  BottomNavDestination(icon: Icons.location_on_rounded, label: 'Contact'),
  BottomNavDestination(
    // The PWA's Donate label is literally "❤️ Donate" (a red heart emoji
    // baked into the text), but the team asked to drop the emoji from the
    // Flutter app's label specifically -- kept as plain "Donate" here,
    // while still keeping the always-gold icon color and the pulse
    // animation that also match the PWA (see [color]'s doc comment).
    icon: Icons.favorite_rounded,
    label: 'Donate',
    pulse: true,
    color: AppColors.gold,
  ),
];
