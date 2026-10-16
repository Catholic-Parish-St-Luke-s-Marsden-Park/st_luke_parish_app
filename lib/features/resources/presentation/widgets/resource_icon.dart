import 'package:flutter/material.dart';

import '../../domain/entities/resource_link.dart';

/// The icon shown on each Resources row.
IconData resourceIcon(ResourceKind kind) => switch (kind) {
  ResourceKind.bulletin => Icons.article_outlined,
  ResourceKind.prayerRequest => Icons.volunteer_activism_outlined,
  ResourceKind.donate => Icons.favorite_outline,
  ResourceKind.church => Icons.public,
  ResourceKind.news => Icons.newspaper_outlined,
  ResourceKind.bible => Icons.menu_book_outlined,
  ResourceKind.readings => Icons.auto_stories_outlined,
  ResourceKind.video => Icons.play_circle_outline,
  ResourceKind.podcast => Icons.local_fire_department_outlined,
  ResourceKind.children => Icons.child_care_outlined,
  ResourceKind.prayers => Icons.self_improvement,
  ResourceKind.saints => Icons.star_outline,
  // The rushing wind of Pentecost.
  ResourceKind.renewal => Icons.air,
  ResourceKind.reflections => Icons.wb_twilight_outlined,
};
