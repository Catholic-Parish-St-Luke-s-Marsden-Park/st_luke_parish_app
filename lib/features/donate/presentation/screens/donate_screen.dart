import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/donate_config.dart';
import '../widgets/bank_detail_row.dart';
import '../widgets/donate_card.dart';
import '../widgets/donate_hero_banner.dart';
import '../widgets/giving_area_row.dart';

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
        // Fr Gayan's letter and what a gift supports both pull down, so the
        // page opens short (parish request, 2026-10-16).
        DonateCard(
          child: _PullDownSection(
            title: DonateConfig.messageTitle,
            icon: Icons.mail_outline_rounded,
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
          child: _PullDownSection(
            title: 'Your gift supports',
            icon: Icons.volunteer_activism_outlined,
            children: [
              for (final area in DonateConfig.givingAreas)
                GivingAreaRow(area: area),
              const SizedBox(height: 8),
              Text(DonateConfig.alsoPayFor, style: textTheme.bodySmall),
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

/// A Donate-card heading (icon and display title) that pulls down to show
/// [children].
class _PullDownSection extends StatelessWidget {
  const _PullDownSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Transparent Material so the ripple shows on the white card; the Theme
    // drops ExpansionTile's divider lines.
    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.primaryNavy,
          leading: ExcludeSemantics(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.paleGold,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryNavy, size: 22),
            ),
          ),
          title: Text(
            title,
            style: AppTypography.display(
              fontSize: 19,
              color: AppColors.primaryNavy,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}
