import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mass_schedule_provider.dart';
import '../widgets/masses_hero_banner.dart';
import '../widgets/reconciliation_and_sacraments_section.dart';
import '../widgets/whats_on_section.dart';

/// Masses tab destination: hero banner + the static "What's On" and
/// "Reconciliation & Sacraments" sections (REQ-F04-001..024). Content is
/// read through [massScheduleProvider] rather than the static config
/// directly (REQ-F04-017); no business logic lives in this widget tree —
/// row/card/section rendering is delegated to small reusable widgets
/// (REQ-F04-019).
class MassesScreen extends ConsumerWidget {
  const MassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(massScheduleProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const MassesHeroBanner(),
        WhatsOnSection(subGroups: schedule.whatsOnSubGroups),
        ReconciliationAndSacramentsSection(
          rows: schedule.reconciliationAndSacraments,
        ),
      ],
    );
  }
}
