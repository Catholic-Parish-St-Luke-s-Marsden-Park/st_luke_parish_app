import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mass_times_card.dart';
import 'mass_symbol_icon.dart';

/// Size of the icon before each Mass times card title.
const double massTimesCardIconSize = 22;

/// The icon shown before each Mass times card title: a chalice and the
/// host for the Saturday Vigil and Sunday Masses, and a calendar for
/// weekdays.
Widget massTimesCardIcon(MassTimesCardKind kind) => switch (kind) {
  MassTimesCardKind.saturdayVigil ||
  MassTimesCardKind.sunday => const MassSymbolIcon(
    color: AppColors.lightGold,
    // Drawn larger than the calendar glyph, which has built-in padding,
    // so the two look the same size.
    size: 28,
  ),
  MassTimesCardKind.weekday => const Icon(
    Icons.calendar_today_outlined,
    color: AppColors.lightGold,
    size: massTimesCardIconSize,
  ),
};
