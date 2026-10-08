import 'package:flutter/material.dart';

/// A nav-bar icon that gently pulses (scales up and back down) on an
/// infinite loop.
///
/// Used only for the "Donate" bottom-nav destination, to draw a little
/// extra attention to it -- mirrors the `heartbeat` CSS animation already
/// on the parish PWA's own Donate nav icon
/// (`stlukes-marsden-park-app/index.html`: `scale(1)` -> `scale(1.2)` ->
/// `scale(1)` every 1.5s, ease, infinite), which the Flutter rewrite had
/// not carried over. Every other bottom-nav icon stays static, matching
/// the PWA, where only the Donate icon animates.
class PulsingNavIcon extends StatefulWidget {
  const PulsingNavIcon({required this.icon, super.key});

  final IconData icon;

  /// Set to `true` by the widget-test suite's global setup (see
  /// `test/flutter_test_config.dart`) so this icon renders statically
  /// during `flutter test` instead of running an infinitely-repeating
  /// animation. `WidgetTester.pumpAndSettle()` waits for every animation
  /// to finish and never terminates while an `AnimationController.repeat()`
  /// is still ticking -- left enabled, this flag would otherwise time out
  /// every widget test that builds the full `AppShell` (via `pumpAndSettle`
  /// in `_pumpShell`/`pumpApp`/`pumpShell`-style helpers across the suite),
  /// not just tests that specifically exercise this widget.
  static bool disableForTesting = false;

  @override
  State<PulsingNavIcon> createState() => _PulsingNavIconState();
}

class _PulsingNavIconState extends State<PulsingNavIcon>
    with SingleTickerProviderStateMixin {
  // Half of the PWA's 1.5s cycle: AnimationController.repeat(reverse: true)
  // plays forward then backward, so 750ms each way reproduces the same
  // ~1.5s scale(1) -> scale(1.2) -> scale(1) period.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..repeat(reverse: true);

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ).drive(Tween<double>(begin: 1, end: 1.2));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respects the system's "reduce motion" accessibility setting, same as
    // any other animated widget in Flutter -- skips the pulse entirely
    // rather than forcing it on users who've asked for less motion. Also
    // skipped in widget tests -- see [PulsingNavIcon.disableForTesting]'s
    // doc comment.
    if (PulsingNavIcon.disableForTesting ||
        MediaQuery.of(context).disableAnimations) {
      return Icon(widget.icon);
    }
    return ScaleTransition(scale: _scale, child: Icon(widget.icon));
  }
}
