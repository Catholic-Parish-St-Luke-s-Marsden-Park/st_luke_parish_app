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
      // Extra room at the end so the last card can scroll clear of the
      // floating announcement button.
      padding: const EdgeInsets.only(bottom: 96),
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
