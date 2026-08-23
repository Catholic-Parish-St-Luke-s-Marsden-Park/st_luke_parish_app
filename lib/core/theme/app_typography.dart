import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens: Playfair Display for display/heading text,
/// Source Sans 3 for body/UI text.
abstract final class AppTypography {
  static TextStyle display({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.sourceSans3(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get navLabel =>
      body(fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.08);

  static TextStyle get parishName => display(
    fontSize: 17,
    height: 1.2,
    letterSpacing: 0.01,
    color: Colors.white,
  );

  static TextStyle get buttonLabel =>
      body(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.04);

  static TextTheme textTheme() {
    final base = GoogleFonts.sourceSans3TextTheme();
    return base.copyWith(
      displayLarge: display(fontSize: 26),
      displayMedium: display(fontSize: 24),
      displaySmall: display(fontSize: 20),
      headlineLarge: display(fontSize: 20),
      headlineMedium: display(fontSize: 18),
      headlineSmall: display(fontSize: 16),
      titleLarge: display(fontSize: 17, fontWeight: FontWeight.w600),
      titleMedium: body(fontSize: 15, fontWeight: FontWeight.w600),
      titleSmall: body(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: body(fontSize: 15),
      bodyMedium: body(fontSize: 14, height: 1.6),
      bodySmall: body(fontSize: 13, color: AppColors.textMuted),
      labelLarge: body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.04,
      ),
      labelMedium: body(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08,
      ),
      labelSmall: body(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.08,
      ),
    );
  }
}
