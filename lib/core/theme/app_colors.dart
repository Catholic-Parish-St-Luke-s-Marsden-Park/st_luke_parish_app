import 'package:flutter/material.dart';

/// Brand palette for St Luke's Parish Marsden Park: navy/gold/cream.
abstract final class AppColors {
  static const Color primaryNavy = Color(0xFF1B3A6B);
  static const Color midBlue = Color(0xFF254D8F);
  static const Color lightBlue = Color(0xFF3A6BB5);

  static const Color gold = Color(0xFFC9A030);
  static const Color lightGold = Color(0xFFE8C060);
  static const Color paleGold = Color(0xFFFDF3D0);

  static const Color cream = Color(0xFFF8F6F1);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A6A);
  static const Color textMuted = Color(0xFF6B7A99);

  static const Color border = Color(0x1F1B3A6B);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, lightBlue],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, lightGold],
  );
}
