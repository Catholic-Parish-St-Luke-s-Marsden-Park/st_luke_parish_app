import 'package:flutter/material.dart';

import '../widgets/bulletins_section.dart';
import '../widgets/news_hero_banner.dart';
import '../widgets/parish_news_section.dart';
import '../widgets/prayer_intentions_section.dart';

/// News tab destination: hero banner + the three sections, in order —
/// "Latest Bulletins" (live, async), "Parish News" (static), and "Submit a
/// Prayer Request" (static) — REQ-F05-031. No business logic, network
/// calls, XML parsing, or regex extraction lives in this widget tree
/// (REQ-F05-032); async bulletin data is read via `BulletinsSection`'s own
/// `ref.watch(bulletinsProvider)`.
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        NewsHeroBanner(),
        BulletinsSection(),
        ParishNewsSection(),
        PrayerIntentionsSection(),
      ],
    );
  }
}
