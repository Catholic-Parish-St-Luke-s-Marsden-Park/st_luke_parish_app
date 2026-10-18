import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/rosary_how_to_config.dart';
import '../../domain/entities/rosary_step.dart';
import 'rosary_diagram.dart';

/// "How to Pray the Rosary": a pull-down card that walks through the
/// card's ten steps one at a time, with an animated rosary showing which
/// beads each step is prayed on, and the words of its prayers (parish
/// request, 2026-10-18).
class HowToPrayRosaryCard extends StatelessWidget {
  const HowToPrayRosaryCard({super.key, this.todaysMysteries});

  /// e.g. "The Glorious Mysteries", shown on the steps that announce a
  /// Mystery.
  final String? todaysMysteries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: AppShapes.cardBorderRadius,
        boxShadow: AppShapes.cardShadow,
      ),
      child: Material(
        color: AppColors.surfaceWhite,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.cardBorderRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primaryNavy, width: 8),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.primaryNavy,
              title: Text(
                'How to Pray the Rosary',
                style: AppTypography.display(
                  fontSize: 19,
                  color: AppColors.primaryNavy,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Step by step, bead by bead',
                  style: textTheme.bodySmall,
                ),
              ),
              children: [
                Text(
                  rosaryHowToIntro,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _RosaryStepper(todaysMysteries: todaysMysteries),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RosaryStepper extends StatefulWidget {
  const _RosaryStepper({required this.todaysMysteries});

  final String? todaysMysteries;

  @override
  State<_RosaryStepper> createState() => _RosaryStepperState();
}

class _RosaryStepperState extends State<_RosaryStepper> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final step = rosarySteps[_index];
    final isLast = _index == rosarySteps.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Semantics(
              label:
                  'Rosary diagram, highlighting the beads for step '
                  '${_index + 1}',
              child: ExcludeSemantics(child: RosaryDiagram(group: step.beads)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'STEP ${_index + 1} OF ${rosarySteps.length}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.darkGold,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (_index + 1) / rosarySteps.length),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    color: AppColors.gold,
                    backgroundColor: AppColors.paleGold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // The step's words fade across when moving between steps.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(_index),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                step.instruction,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryNavy,
                  height: 1.4,
                ),
              ),
              if (step.announcesMystery && widget.todaysMysteries != null) ...[
                const SizedBox(height: 6),
                Text(
                  "Today's Mysteries: ${widget.todaysMysteries}",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              for (final prayer in step.prayers) ...[
                const SizedBox(height: 10),
                _PrayerBox(prayer: prayer),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _index == 0 ? null : () => _go(_index - 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _go(isLast ? 0 : _index + 1),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: Icon(
                  isLast ? Icons.replay_rounded : Icons.chevron_right_rounded,
                ),
                label: Text(isLast ? 'Start again' : 'Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayerBox extends StatelessWidget {
  const _PrayerBox({required this.prayer});

  final RosaryPrayer prayer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paleGold.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prayer.name,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prayer.text,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
