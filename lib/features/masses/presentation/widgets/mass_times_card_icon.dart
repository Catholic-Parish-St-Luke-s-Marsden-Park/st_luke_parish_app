import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mass_times_card.dart';
import 'mass_symbol_icon.dart';

/// The icon shown before each Mass times card title: the same chalice and
/// host on all three cards (parish request, 2026-10-16).
Widget massTimesCardIcon(MassTimesCardKind kind) =>
    const MassSymbolIcon(color: AppColors.lightGold, size: 28);
