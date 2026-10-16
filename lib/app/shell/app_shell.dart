import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../features/donate/presentation/screens/donate_screen.dart';
import '../../features/masses/presentation/screens/masses_screen.dart';
import '../../features/ministries/presentation/screens/ministries_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/parish/presentation/screens/parish_screen.dart';
import '../../features/parish/presentation/widgets/announcement_button.dart';
import 'bottom_nav.dart';
import 'nav_index_provider.dart';
import 'side_drawer.dart';
import 'widgets/app_bar_logo.dart';
import 'widgets/ask_luke_pill.dart';
import 'widgets/pulsing_nav_icon.dart';
import 'widgets/saint_of_the_day_pill.dart';

/// Hosts the bottom-nav + side-drawer chrome and swaps between the 6
/// primary tabs using an [IndexedStack], preserving each tab's state.
///
/// The `AppBar` (wordmark logo + "Saint of the Day"/"Ask Luke" pills) is
/// shared app-level chrome rendered identically regardless of the selected
/// tab — it intentionally carries no per-tab text title (REQ-F02-016a).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  /// Largest text scale the AppBar buttons honour (see the AppBar actions).
  static const double appBarPillMaxTextScale = 1.3;

  static const _tabBuilders = <Widget Function()>[
    ParishScreen.new,
    MassesScreen.new,
    NewsScreen.new,
    MinistriesScreen.new,
    ContactScreen.new,
    DonateScreen.new,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    return _AppShellBody(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) =>
          ref.read(selectedNavIndexProvider.notifier).select(index),
    );
  }
}

class _AppShellBody extends StatefulWidget {
  const _AppShellBody({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<_AppShellBody> createState() => _AppShellBodyState();
}

class _AppShellBodyState extends State<_AppShellBody> {
  /// Tabs are built lazily (and then kept alive) so screens with future
  /// network-backed content aren't built until the user visits that tab.
  final Set<int> _visited = {0};

  @override
  void didUpdateWidget(covariant _AppShellBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visited.add(widget.selectedIndex);
  }

  /// Screen width minus the menu button, the title spacing (applied on both
  /// sides of the title) and the logo chip.
  double _pillsMaxWidth(BuildContext context) =>
      (MediaQuery.sizeOf(context).width -
              kToolbarHeight -
              2 * _titleSpacing -
              AppBarLogo.chipWidth)
          .clamp(0.0, double.infinity);

  static const double _titleSpacing = 4;

  Widget _cappedPill(Widget pill) => MediaQuery.withClampedTextScaling(
    maxScaleFactor: AppShell.appBarPillMaxTextScale,
    child: pill,
  );

  @override
  Widget build(BuildContext context) {
    final tabBuilders = AppShell._tabBuilders;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _titleSpacing,
        title: const AppBarLogo(),
        // The two pills share whatever width the logo leaves and ellipsize
        // their labels, rather than overflowing the toolbar on a narrow phone
        // or at an increased text scale. Their total width is capped so the
        // logo always keeps its full chip width, and their text scale is
        // capped so a huge system text size can't crowd it either; the rest
        // of the app still scales fully.
        actions: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _pillsMaxWidth(context)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: _cappedPill(const SaintOfTheDayPill())),
                  const SizedBox(width: 8),
                  Flexible(child: _cappedPill(const AskLukePill())),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const SideDrawer(),
      // Only on the Parish tab, and only while the parish website has a
      // pop-up announcement (parish request, 2026-10-16).
      floatingActionButton: widget.selectedIndex == 0
          ? const AnnouncementButton()
          : null,
      body: IndexedStack(
        index: widget.selectedIndex,
        children: [
          for (var i = 0; i < tabBuilders.length; i++)
            _visited.contains(i) ? tabBuilders[i]() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: [
          for (final destination in bottomNavDestinations)
            NavigationDestination(
              icon: destination.pulse
                  ? PulsingNavIcon(
                      icon: destination.icon,
                      color: destination.color,
                    )
                  : Icon(destination.icon, color: destination.color),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
