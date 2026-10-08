import 'package:flutter/material.dart';

/// Static configuration for the 6 bottom-navigation destinations.
class BottomNavDestination {
  const BottomNavDestination({
    required this.icon,
    required this.label,
    this.pulse = false,
  });

  final IconData icon;
  final String label;

  /// Whether this destination's icon should gently pulse to draw a little
  /// extra attention to it -- currently only the Donate tab, mirroring the
  /// `heartbeat` animation already on the parish PWA's own Donate nav icon
  /// (see [PulsingNavIcon]'s doc comment for the source of truth).
  final bool pulse;
}

const List<BottomNavDestination> bottomNavDestinations = [
  BottomNavDestination(icon: Icons.church_rounded, label: 'Parish'),
  BottomNavDestination(icon: Icons.calendar_month_rounded, label: 'Masses'),
  BottomNavDestination(icon: Icons.article_rounded, label: 'News'),
  BottomNavDestination(icon: Icons.groups_rounded, label: 'Ministries'),
  BottomNavDestination(icon: Icons.location_on_rounded, label: 'Contact'),
  BottomNavDestination(
    icon: Icons.favorite_rounded,
    label: 'Donate',
    pulse: true,
  ),
];
