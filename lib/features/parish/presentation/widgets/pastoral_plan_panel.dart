import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/pastoral_plan_config.dart';
import '../providers/parish_documents_provider.dart';

/// The Pastoral Plan at the end of the "About St Luke's" card: the four
/// pillars in words and as the parish's graphic, then buttons that open
/// the full plan and the latest Parish Pastoral Council minutes (PDFs) in
/// the device's browser. The minutes link is read from the parish home
/// page each time, so it follows the parish's monthly updates.
class PastoralPlanPanel extends ConsumerWidget {
  const PastoralPlanPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutesUrl = switch (ref.watch(latestCouncilMinutesUrlProvider)) {
      AsyncData(:final value) => value,
      // Still loading, or the home page couldn't be read: open the minutes
      // known when this build was made, so the button always works.
      _ => PastoralPlanConfig.councilMinutesUrl,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32, color: AppColors.border),
        Semantics(
          header: true,
          child: Text(
            PastoralPlanConfig.title,
            style: AppTypography.display(
              fontSize: 17,
              color: AppColors.primaryNavy,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          PastoralPlanConfig.summary,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Image.asset(
              PastoralPlanConfig.pillarsAsset,
              semanticLabel: PastoralPlanConfig.pillarsImageLabel,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => ref
              .read(urlLauncherServiceProvider)
              .launchExternal(PastoralPlanConfig.pdfUrl),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Read our Pastoral Plan'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(urlLauncherServiceProvider).launchExternal(minutesUrl),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryNavy,
            side: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.groups_outlined),
          label: const Text('Pastoral Council Meeting Minutes'),
        ),
      ],
    );
  }
}
