import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/config/rosary_how_to_config.dart';
import '../../domain/entities/rosary_mystery.dart';
import '../../domain/entities/rosary_step.dart';
import 'rosary_diagram.dart';

/// "Pray the Rosary": a pull-down card that walks through the whole
/// Rosary one bead (one prayer) at a time, lighting each bead as the user
/// taps Next, with today's Mysteries (from the phone's day)
/// in their decades, an animated rosary showing which beads each step is
/// prayed on, and the words of its prayers (parish request, 2026-10-18).
class HowToPrayRosaryCard extends StatelessWidget {
  const HowToPrayRosaryCard({super.key, required this.mysteries});

  /// Today's set of Mysteries.
  final RosaryMysterySet mysteries;

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
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.primaryNavy,
              title: Text(
                'Pray the Rosary',
                style: AppTypography.display(
                  fontSize: 19,
                  color: AppColors.primaryNavy,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Today: ${mysteries.name}, step by step",
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
                _RosaryStepper(mysteries: mysteries),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RosaryStepper extends StatefulWidget {
  const _RosaryStepper({required this.mysteries});

  final RosaryMysterySet mysteries;

  @override
  State<_RosaryStepper> createState() => _RosaryStepperState();
}

class _RosaryStepperState extends State<_RosaryStepper> {
  late final List<RosaryStep> _steps = rosaryStepsFor(widget.mysteries);
  int _index = 0;

  static const _ordinals = ['1st', '2nd', '3rd', '4th', '5th'];

  /// The top of the stepper, brought back into view if it has scrolled off,
  /// so the diagram is seen lighting up.
  final _topKey = GlobalKey();

  void _go(int index) {
    setState(() => _index = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final top = _topKey.currentContext;
      if (top == null || !top.mounted) return;
      Scrollable.ensureVisible(
        top,
        duration: MediaQuery.of(top).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  /// e.g. "Hail Mary 3 of 10", for the steps that count Hail Marys.
  static String? _countLabel(RosaryStep step) => switch (step.beads.kind) {
    RosaryBeadKind.introHailMary => 'Hail Mary ${step.beads.bead + 1} of 3',
    RosaryBeadKind.decadeHailMary => 'Hail Mary ${step.beads.bead + 1} of 10',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;
    final decade = step.decade;

    return Column(
      key: _topKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Semantics(
              label:
                  'Rosary diagram, showing the beads prayed so far, step '
                  '${_index + 1}',
              child: ExcludeSemantics(
                child: RosaryDiagram(
                  path: [
                    for (final earlier in _steps.take(_index + 1))
                      earlier.beads,
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The step count above a full-width progress bar, so it fits at any
        // text size.
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'STEP ${_index + 1} OF ${_steps.length}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.darkGold,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (_index + 1) / _steps.length),
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
        const SizedBox(height: 12),
        // Back and Next sit just under the rosary, so the user can keep
        // tapping Next through the prayers without scrolling.
        _StepButtons(
          onBack: _index == 0 ? null : () => _go(_index - 1),
          onNext: () => _go(isLast ? 0 : _index + 1),
          isLast: isLast,
        ),
        if (decade != null || _countLabel(step) != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (decade != null)
                Text(
                  '${_ordinals[decade]} Decade',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (_countLabel(step) case final count?)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
              if (step.mystery case final mystery?) ...[
                const SizedBox(height: 10),
                _MysteryPanel(
                  mystery: mystery,
                  label:
                      '${_ordinals[decade!]} ${widget.mysteries.adjective} '
                      'Mystery',
                  // Announcing shows the whole Mystery; while praying the
                  // decade, a reminder of what to meditate on.
                  full: step.beads.kind == RosaryBeadKind.decadeOurFather,
                ),
              ],
              for (final prayer in step.prayers) ...[
                const SizedBox(height: 10),
                _PrayerBox(prayer: prayer),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Back and Next, side by side; stacked when large system text would make
/// them too wide to sit together.
class _StepButtons extends StatelessWidget {
  const _StepButtons({
    required this.onBack,
    required this.onNext,
    required this.isLast,
  });

  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final back = OutlinedButton.icon(
      onPressed: onBack,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryNavy,
        minimumSize: const Size.fromHeight(48),
      ),
      icon: const Icon(Icons.chevron_left_rounded),
      label: const Text('Back'),
    );
    final next = FilledButton.icon(
      onPressed: onNext,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
      icon: Icon(isLast ? Icons.replay_rounded : Icons.chevron_right_rounded),
      label: Text(isLast ? 'Start again' : 'Next'),
    );

    if (MediaQuery.textScalerOf(context).scale(1) > 1.4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [next, const SizedBox(height: 8), back],
      );
    }
    return Row(
      children: [
        Expanded(child: back),
        const SizedBox(width: 10),
        Expanded(child: next),
      ],
    );
  }
}

/// Today's Mystery for the current decade: its picture, label and title,
/// and when [full], its Scripture and fruit.
class _MysteryPanel extends StatelessWidget {
  const _MysteryPanel({
    required this.mystery,
    required this.label,
    required this.full,
  });

  final RosaryMystery mystery;
  final String label;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    mystery.imageAsset,
                    width: full ? 96 : 64,
                    height: full ? 104 : 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (full ? label : 'Meditate on').toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.darkGold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mystery.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNavy,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (full) ...[
            const SizedBox(height: 10),
            Text(
              mystery.verse,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 2),
            Text(mystery.reference, style: textTheme.bodySmall),
          ],
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Fruit of the Mystery: '),
                TextSpan(
                  text: mystery.fruit,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
