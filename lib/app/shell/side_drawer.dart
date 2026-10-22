import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/masses/data/config/divine_mercy_config.dart';
import '../../features/masses/presentation/screens/divine_mercy_screen.dart';
import '../../features/masses/presentation/screens/rosary_screen.dart';
import '../../features/masses/presentation/widgets/rosary_icon.dart';
import '../../features/parish/presentation/widgets/about_st_lukes_section.dart';
import '../../features/resources/data/config/static_resources_config.dart';
import '../../features/resources/domain/entities/resource_link.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import 'nav_index_provider.dart';

/// Side drawer chrome hosting the 5 secondary destinations: the Resources,
/// Faith Formation, The Rosary and Divine Mercy Chaplet pages, and Prayer
/// Request,
/// which opens the parish's prayer-request form in the browser (the same
/// page as the News tab's button).
class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  /// Bottom-nav index of each tab a resource can switch to.
  static const _tabIndex = {AppTab.news: 2, AppTab.donate: 5};

  /// Closes the drawer and opens a [ResourcesScreen] page of [groups].
  void _openLinksPage(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<ResourceGroup> groups,
  }) {
    final navigator = Navigator.of(context);
    // Read now: the drawer (and its ref) is gone by the time a link
    // switches tabs.
    final navIndex = ref.read(selectedNavIndexProvider.notifier);
    final scaffold = Scaffold.maybeOf(context);
    // closeDrawer (not a plain pop) so the drawer is really shut, and not
    // shown again when Resources is closed.
    scaffold?.closeDrawer();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ResourcesScreen(
          title: title,
          groups: groups,
          onOpenTab: (tab) {
            navigator.popUntil((route) => route.isFirst);
            scaffold?.closeDrawer();
            navIndex.select(_tabIndex[tab]!);
          },
        ),
      ),
    );
  }

  /// MARSDEN PARK in the menu header.
  static const _spaced = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        // Scrolls, so every entry can be reached with large system text.
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: Row(
                children: [
                  // The round part of the St Luke's logo, on white so its
                  // blue ring stands out from the navy (parish request,
                  // 2026-10-19).
                  ExcludeSemantics(
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(AboutStLukesSection.emblemAsset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // The full name on one line in the heading font (shrunk
                  // only if it would not fit), then MARSDEN PARK in spaced
                  // capitals under a gold rule, as on the parish logo
                  // (parish request, 2026-10-22).
                  Expanded(
                    child: Semantics(
                      header: true,
                      label: "St Luke's Catholic Parish, Marsden Park",
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                "St Luke's Catholic Parish",
                                maxLines: 1,
                                style: AppTypography.display(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.gold,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: const Text('MARSDEN PARK', style: _spaced),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'MORE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Resources'),
              onTap: () => _openLinksPage(
                context,
                ref,
                title: 'Resources',
                groups: resourceGroups,
              ),
            ),
            ListTile(
              // The flame of the Holy Spirit; distinct from Resources' book.
              leading: const Icon(Icons.local_fire_department_rounded),
              title: const Text('Faith Formation'),
              onTap: () => _openLinksPage(
                context,
                ref,
                title: 'Faith Formation',
                groups: faithFormationGroups,
              ),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: RosaryIcon(color: AppColors.textSecondary),
              ),
              title: const Text('The Rosary'),
              onTap: () {
                final navigator = Navigator.of(context);
                Scaffold.maybeOf(context)?.closeDrawer();
                navigator.push(
                  MaterialPageRoute(builder: (_) => const RosaryScreen()),
                );
              },
            ),
            ListTile(
              // A small round crop of the Divine Mercy image itself: the face
              // and the rays from the Heart.
              leading: ExcludeSemantics(
                child: ClipOval(
                  child: Image.asset(
                    divineMercyImage,
                    // The standard icon size, so its label lines up.
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.6),
                  ),
                ),
              ),
              title: const Text('Divine Mercy Chaplet'),
              onTap: () {
                final navigator = Navigator.of(context);
                Scaffold.maybeOf(context)?.closeDrawer();
                navigator.push(
                  MaterialPageRoute(builder: (_) => const DivineMercyScreen()),
                );
              },
            ),
            // No Prayer Request entry: it is on the News tab's "Submit a
            // Prayer Request" section (parish request, 2026-10-22).
          ],
        ),
      ),
    );
  }
}
