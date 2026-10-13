import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/shell/widgets/pulsing_nav_icon.dart';

/// Covers [PulsingNavIcon] directly: the actual pulse animation (with the
/// suite-wide [PulsingNavIcon.disableForTesting] kill switch -- see
/// `test/flutter_test_config.dart` -- temporarily turned back off), the
/// kill switch itself, and the "reduce motion" accessibility fallback.
///
/// Every test here uses `tester.pump(duration)`, never `pumpAndSettle()`:
/// this widget's whole reason for having a disable-for-testing switch is
/// that its `AnimationController.repeat()` never settles, so
/// `pumpAndSettle()` would time out on it exactly like it did suite-wide
/// before that switch existed.
void main() {
  setUp(() {
    // The global test setup (`test/flutter_test_config.dart`) sets this to
    // `true` for the whole suite. Flip it back off just for this file's
    // "animation actually runs" tests, and restore it afterwards so no
    // other test file is affected.
    PulsingNavIcon.disableForTesting = false;
  });

  tearDown(() {
    PulsingNavIcon.disableForTesting = true;
  });

  Future<void> pumpIcon(WidgetTester tester, {bool disableAnimations = false}) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: const Scaffold(
            body: PulsingNavIcon(icon: Icons.favorite_rounded),
          ),
        ),
      ),
    );
  }

  // MaterialApp's own initial-route entrance animation (the default
  // Material 3 "Zoom" page-transition builder) also renders a
  // ScaleTransition, unrelated to PulsingNavIcon -- so every finder below
  // is scoped to descendants of PulsingNavIcon itself, same pattern as
  // test/shared/widgets/app_pill_button_test.dart.
  Finder scaleTransitionInIcon() => find.descendant(
    of: find.byType(PulsingNavIcon),
    matching: find.byType(ScaleTransition),
  );

  testWidgets('pulses: scales up from 1.0 towards 1.2 and back down over one '
      '1.5s cycle', (tester) async {
    await pumpIcon(tester);

    ScaleTransition findScaleTransition() =>
        tester.widget<ScaleTransition>(scaleTransitionInIcon());

    // Starting scale is 1.0 (animation begins at the controller's
    // lower bound, before any time has elapsed).
    expect(findScaleTransition().scale.value, 1.0);

    // Halfway through the "forward" half of the cycle (375ms of 750ms),
    // the icon should have grown, but not yet reached the 1.2 peak.
    await tester.pump(const Duration(milliseconds: 375));
    final midForward = findScaleTransition().scale.value;
    expect(midForward, greaterThan(1.0));
    expect(midForward, lessThan(1.2));

    // At 750ms (the full forward half), the scale peaks at 1.2.
    await tester.pump(const Duration(milliseconds: 375));
    expect(findScaleTransition().scale.value, closeTo(1.2, 0.001));

    // A further 750ms (the "reverse" half, AnimationController.repeat's
    // reverse: true) brings it back down to 1.0 -- confirming this is a
    // genuine up-and-down pulse, not a one-shot scale-up.
    await tester.pump(const Duration(milliseconds: 750));
    expect(findScaleTransition().scale.value, closeTo(1.0, 0.001));

    // And it keeps going -- the controller is still ticking, proving
    // this is the infinite loop PulsingNavIcon.disableForTesting exists
    // to guard against in the rest of the suite.
    await tester.pump(const Duration(milliseconds: 375));
    expect(findScaleTransition().scale.value, greaterThan(1.0));
  });

  testWidgets('disableForTesting: renders a plain, non-animating Icon, no '
      'ScaleTransition', (tester) async {
    PulsingNavIcon.disableForTesting = true;
    await pumpIcon(tester);

    expect(scaleTransitionInIcon(), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets(
    "MediaQuery's disableAnimations (reduce-motion accessibility setting): "
    'renders a plain, non-animating Icon, no ScaleTransition',
    (tester) async {
      await pumpIcon(tester, disableAnimations: true);

      expect(scaleTransitionInIcon(), findsNothing);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    },
  );
}
