import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/contact/presentation/screens/contact_screen.dart';
import '../../features/donate/presentation/screens/donate_screen.dart';
import '../../features/masses/presentation/screens/masses_screen.dart';
import '../../features/ministries/presentation/screens/ministries_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/parish/presentation/screens/parish_screen.dart';
import '../../features/parish/presentation/providers/parish_notice_provider.dart';
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
    // Check the parish home page for a pop-up announcement once, when the
    // app opens, so the side menu already knows whether to offer Special
    // Announcements. Listening (not watching) keeps it loaded without
    // rebuilding the shell.
    ref.listen(currentParishNoticeProvider, (_, _) {});

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

  @override
  Widget build(BuildContext context) {
    final tabBuilders = AppShell._tabBuilders;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: const AppBarLogo(),
        // Both pills are Flexible so they share whatever width the logo
        // leaves and ellipsize their labels, rather than overflowing the
        // toolbar on a narrow phone or at an increased text scale.
        actions: const [
          Flexible(child: SaintOfTheDayPill()),
          SizedBox(width: 8),
          Flexible(child: AskLukePill()),
          SizedBox(width: 8),
        ],
      ),
      drawer: const SideDrawer(),
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
