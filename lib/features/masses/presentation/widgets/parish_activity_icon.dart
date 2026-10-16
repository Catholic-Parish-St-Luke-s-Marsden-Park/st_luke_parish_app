import 'package:flutter/material.dart';

import '../../domain/entities/parish_activity.dart';
import 'rosary_icon.dart';

/// The icon shown on each "Regular Activities" ribbon. Material has no
/// praying-hands glyph, so Prayer Ministry uses the closest match, and the
/// Rosary before Mass uses a painted rosary.
Widget parishActivityIcon(
  ParishActivityKind kind, {
  required Color color,
  double size = 24,
}) {
  if (kind == ParishActivityKind.prayRosary) {
    return RosaryIcon(color: color, size: size);
  }
  return Icon(_materialIcon(kind), color: color, size: size);
}

IconData _materialIcon(ParishActivityKind kind) => switch (kind) {
  ParishActivityKind.communionToSick => Icons.volunteer_activism_outlined,
  ParishActivityKind.reconciliation => Icons.forum_outlined,
  ParishActivityKind.childrensLiturgy => Icons.child_care_outlined,
  ParishActivityKind.baptism => Icons.water_drop_outlined,
  ParishActivityKind.marriage => Icons.favorite_outline,
  ParishActivityKind.sacraments => Icons.church_outlined,
  ParishActivityKind.youth => Icons.groups_outlined,
  ParishActivityKind.scripture => Icons.school_outlined,
  ParishActivityKind.cuppa => Icons.coffee_outlined,
  ParishActivityKind.foodStall => Icons.storefront_outlined,
  ParishActivityKind.prayer => Icons.self_improvement,
  ParishActivityKind.careCommunity => Icons.elderly,
  ParishActivityKind.rosary => Icons.local_florist_outlined,
  ParishActivityKind.faithGroup => Icons.menu_book_outlined,
  ParishActivityKind.prayRosary => Icons.circle_outlined,
};
