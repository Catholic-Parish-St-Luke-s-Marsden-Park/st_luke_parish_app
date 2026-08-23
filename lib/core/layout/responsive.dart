import 'package:flutter/material.dart';

/// Mobile-only responsive breakpoints (phone vs. tablet widths). No web
/// breakpoints are needed since this app targets Android/iOS only.
abstract final class Responsive {
  /// Widths at or above this are treated as tablet-sized.
  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Adaptive horizontal content padding: tighter on phones, roomier on
  /// tablets so content doesn't stretch edge-to-edge.
  static EdgeInsets pagePadding(BuildContext context) {
    final horizontal = isTablet(context) ? 32.0 : 16.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  /// Clamps content to a comfortable reading width on tablets while filling
  /// the available width on phones.
  static double maxContentWidth(BuildContext context) =>
      isTablet(context) ? 720 : double.infinity;
}
