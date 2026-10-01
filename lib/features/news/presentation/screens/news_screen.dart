import 'package:flutter/material.dart';

import '../../../events/presentation/widgets/events_section.dart';
import '../widgets/bulletins_section.dart';
import '../widgets/news_hero_banner.dart';
import '../widgets/parish_news_section.dart';
import '../widgets/prayer_intentions_section.dart';

/// News tab destination: hero banner + four sections, in order —
/// "Upcoming Events" (live, async, REQ-F08-031), "Latest Bulletins" (live,
/// async), "Parish News" (static), and "Submit a Prayer Request" (static) —
/// REQ-F05-031. No business logic, network calls, parsing, or export calls
/// live in this widget tree (REQ-F05-032, REQ-F08-033); async data is read
/// via `EventsSection`'s/`BulletinsSection`'s own `ref.watch(...)` calls.
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        NewsHeroBanner(),
        EventsSection(),
        BulletinsSection(),
        ParishNewsSection(),
        PrayerIntentionsSection(),
      ],
    );
  }
}
