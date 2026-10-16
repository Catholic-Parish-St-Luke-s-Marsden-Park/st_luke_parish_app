import 'package:flutter/material.dart';

import '../widgets/about_st_lukes_section.dart';
import '../widgets/church_leadership_section.dart';
import '../widgets/new_to_marsden_park_section.dart';
import '../widgets/parish_hero_banner.dart';
import '../widgets/parish_prayer_section.dart';

/// Parish home destination: hero banner, the "Our Story" (About St Luke's)
/// pull-down card, then the 3-part "Church Leadership" section (Universal
/// Church / Diocese of Parramatta / Parish), the "New to Marsden Park?"
/// welcome card, then "Our Parish Prayer" at the bottom (parish requests,
/// 2026-10-15 and 2026-10-16).
class ParishScreen extends StatelessWidget {
  const ParishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        ParishHeroBanner(),
        AboutStLukesSection(),
        ChurchLeadershipSectionWidget(),
        NewToMarsdenParkSection(),
        ParishPrayerSection(),
      ],
    );
  }
}
