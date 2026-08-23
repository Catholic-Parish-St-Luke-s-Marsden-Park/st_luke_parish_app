import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shape/elevation tokens: card radius, pill radius, navy-tinted shadow.
abstract final class AppShapes {
  static const double cardRadius = 12.0;
  static const double pillRadius = 20.0;
  static const double smallRadius = 8.0;
  static const double sheetRadius = 20.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(
    cardRadius,
  );
  static final BorderRadius pillBorderRadius = BorderRadius.circular(
    pillRadius,
  );
  static const BorderRadius sheetBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(sheetRadius),
    topRight: Radius.circular(sheetRadius),
  );

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.primaryNavy.withValues(alpha: 0.10),
      offset: const Offset(0, 2),
      blurRadius: 12,
    ),
  ];
}
