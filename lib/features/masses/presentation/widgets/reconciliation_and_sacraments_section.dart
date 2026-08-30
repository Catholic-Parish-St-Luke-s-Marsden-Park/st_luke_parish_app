import 'package:flutter/material.dart';

import '../../domain/entities/mass_time.dart';
import 'mass_card.dart';
import 'mass_row.dart';
import 'mass_section_header.dart';

/// Section 2 — "Reconciliation & Sacraments": a single card with a flat
/// list of rows, in order (REQ-F04-009, REQ-F04-010).
class ReconciliationAndSacramentsSection extends StatelessWidget {
  const ReconciliationAndSacramentsSection({super.key, required this.rows});

  final List<MassTime> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MassSectionHeader('Reconciliation & Sacraments'),
        MassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final row in rows) MassRow(massTime: row)],
          ),
        ),
      ],
    );
  }
}
