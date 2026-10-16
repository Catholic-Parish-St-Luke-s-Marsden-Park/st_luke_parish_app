import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/config/donate_config.dart';
import '../widgets/bank_detail_row.dart';
import '../widgets/donate_card.dart';
import '../widgets/donate_hero_banner.dart';

/// Donate destination: the parish's message and two ways to give — card
/// (BPOINT, opened in the device's browser) and bank transfer (EFT details
/// with copy buttons). Replaces the in-app WebView of the website's Donate
/// page (parish request, 2026-10-16). Renders as bare tab-body content
/// inside `AppShell`'s shared `AppBar`/`Scaffold` (REQ-F02-016a).
class DonateScreen extends ConsumerWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.6,
    );
    const bank = DonateConfig.bankTransfer;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const DonateHeroBanner(),
        const SizedBox(height: 7),
        DonateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, paragraph) in DonateConfig.letter.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                Text(paragraph, style: bodyStyle),
              ],
              const SizedBox(height: 12),
              Text(
                DonateConfig.signedBy,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryNavy,
                ),
              ),
              Text(DonateConfig.signedByRole, style: textTheme.bodySmall),
            ],
          ),
        ),
        DonateCard(
          title: 'Your gift supports',
          icon: Icons.volunteer_activism_outlined,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in DonateConfig.givingFor)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paleGold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        DonateCard(
          title: 'Donate by card',
          icon: Icons.credit_card_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Give securely through the Commonwealth Bank's BPOINT "
                'payment page, which opens in your browser.',
                style: bodyStyle,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => ref
                    .read(urlLauncherServiceProvider)
                    .launchExternal(DonateConfig.bpointUrl),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Donate by Card'),
              ),
            ],
          ),
        ),
        DonateCard(
          title: 'Bank transfer (EFT)',
          icon: Icons.account_balance_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You can also give by bank transfer from your own banking '
                'app.',
                style: bodyStyle,
              ),
              const SizedBox(height: 8),
              BankDetailRow(label: 'Account name', value: bank.accountName),
              BankDetailRow(label: 'BSB', value: bank.bsb),
              BankDetailRow(label: 'Account number', value: bank.accountNumber),
              BankDetailRow(
                label: 'Reference',
                value: bank.reference,
                copyable: false,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refund policy',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(DonateConfig.refundPolicy, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
