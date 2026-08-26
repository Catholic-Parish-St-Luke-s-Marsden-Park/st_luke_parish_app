import 'package:flutter/material.dart';

import '../widgets/about_st_lukes_section.dart';
import '../widgets/church_leadership_section.dart';
import '../widgets/parish_hero_banner.dart';

/// Parish home destination: hero banner, "About St Luke's" section, and the
/// 3-part "Church Leadership" section (Universal Church / Diocese of
/// Parramatta / Parish).
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
      ],
    );
  }
}
