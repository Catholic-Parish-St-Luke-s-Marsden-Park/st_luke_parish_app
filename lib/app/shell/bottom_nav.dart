import 'package:flutter/material.dart';

/// Static configuration for the 6 bottom-navigation destinations.
class BottomNavDestination {
  const BottomNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<BottomNavDestination> bottomNavDestinations = [
  BottomNavDestination(icon: Icons.church_rounded, label: 'Parish'),
  BottomNavDestination(icon: Icons.calendar_month_rounded, label: 'Masses'),
  BottomNavDestination(icon: Icons.article_rounded, label: 'News'),
  BottomNavDestination(icon: Icons.groups_rounded, label: 'Ministries'),
  BottomNavDestination(icon: Icons.location_on_rounded, label: 'Contact'),
  BottomNavDestination(icon: Icons.favorite_rounded, label: 'Donate'),
];
