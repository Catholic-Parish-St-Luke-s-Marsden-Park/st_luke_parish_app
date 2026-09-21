import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';

/// Measures WCAG 2.1 contrast for the colour pairs the Saint of the Day
/// screen actually renders.
///
/// CLAUDE.md requires 4.5:1 for body text and says "Low-opacity white on
/// the navy gradient is the easiest way to fail this — measure rather
/// than eyeball it". These tests are that measurement, kept executable so
/// a future palette or opacity tweak cannot quietly drop below the floor.
///
/// Gradient backgrounds are checked at their *lightest* stop, which is
/// the worst case for white or pale foreground text.
void main() {
  /// WCAG relative luminance.
  double luminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  /// WCAG contrast ratio between two opaque colours.
  double contrast(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Flattens a translucent [fg] over an opaque [bg], the way the screen
  /// composites it.
  Color flatten(Color fg, Color bg) => Color.from(
    alpha: 1,
    red: fg.r * fg.a + bg.r * (1 - fg.a),
    green: fg.g * fg.a + bg.g * (1 - fg.a),
    blue: fg.b * fg.a + bg.b * (1 - fg.a),
  );

  const aaBodyText = 4.5;

  /// The lightest stop of `heroGradient` — the worst case for the pale
  /// text drawn on it.
  const gradientLightest = AppColors.lightBlue;

  void expectMeetsAA(String description, Color fg, Color bg) {
    final ratio = contrast(fg, bg);
    expect(
      ratio,
      greaterThanOrEqualTo(aaBodyText),
      reason:
          '$description measured ${ratio.toStringAsFixed(2)}:1, '
          'below the WCAG AA floor of $aaBodyText:1',
    );
  }

  group('Saint of the Day header', () {
    test('date pill label on gold meets AA', () {
      expectMeetsAA(
        'textPrimary on gold date pill',
        AppColors.textPrimary,
        AppColors.gold,
      );
    });

    test('saint name (solid white) on the gradient meets AA', () {
      expectMeetsAA(
        'white saint name on heroGradient',
        const Color(0xFFFFFFFF),
        gradientLightest,
      );
    });

    test('feast line meets AA at the light end of the gradient', () {
      // This is the one that failed: at alpha 0.75 it measured 3.76:1.
      final feast = Colors.white.withValues(alpha: 0.92);
      expectMeetsAA(
        'feast line on heroGradient',
        flatten(feast, gradientLightest),
        gradientLightest,
      );
    });
  });

  group('Saint of the Day section card', () {
    test('plain card label on white meets AA', () {
      // textMuted #6B7A99 measured 4.31:1 here and was replaced.
      expectMeetsAA(
        'section label on surfaceWhite',
        AppColors.textSecondary,
        AppColors.surfaceWhite,
      );
    });

    test('plain card body on white meets AA', () {
      expectMeetsAA(
        'section body on surfaceWhite',
        AppColors.textSecondary,
        AppColors.surfaceWhite,
      );
    });

    test('emphasized card label meets AA at the light end of the gradient', () {
      // lightGold #E8C060 measured 3.07:1 here and was replaced.
      expectMeetsAA(
        'emphasized section label on heroGradient',
        AppColors.paleGold,
        gradientLightest,
      );
    });

    test('emphasized card body meets AA at the light end of the gradient', () {
      final body = Colors.white.withValues(alpha: 0.92);
      expectMeetsAA(
        'emphasized section body on heroGradient',
        flatten(body, gradientLightest),
        gradientLightest,
      );
    });
  });

  group('the measurement helper itself', () {
    test('reports the reference extremes correctly', () {
      // Sanity checks so a broken helper cannot silently pass the suite.
      expect(
        contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
      expect(
        contrast(const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)),
        closeTo(1, 0.01),
      );
    });

    test('still flags the values that were failing before this change', () {
      // Guards against the helper drifting into permissiveness.
      expect(
        contrast(AppColors.textMuted, AppColors.surfaceWhite),
        lessThan(aaBodyText),
      );
      expect(
        contrast(AppColors.lightGold, gradientLightest),
        lessThan(aaBodyText),
      );
      expect(
        contrast(
          flatten(Colors.white.withValues(alpha: 0.75), gradientLightest),
          gradientLightest,
        ),
        lessThan(aaBodyText),
      );
    });
  });
}
