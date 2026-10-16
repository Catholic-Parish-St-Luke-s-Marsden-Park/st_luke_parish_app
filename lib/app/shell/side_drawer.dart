import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/external_links.dart';
import '../../core/services/url_launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/resources/data/config/static_resources_config.dart';
import '../../features/resources/domain/entities/resource_link.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import 'nav_index_provider.dart';

/// Side drawer chrome hosting the 3 secondary destinations: the Resources
/// and Faith Formation pages, and Prayer Request, which opens the parish's
/// prayer-request form in the browser (the same page as the News tab's
/// button).
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
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ResourcesScreen(
          title: title,
          groups: groups,
          onOpenTab: (tab) {
            navigator.popUntil((route) => route.isFirst);
            navIndex.select(_tabIndex[tab]!);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "St Luke's Parish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              leading: const Icon(Icons.favorite_border_rounded),
              title: const Text('Prayer Request'),
              trailing: const ExcludeSemantics(
                child: Icon(Icons.open_in_new_rounded, size: 18),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(urlLauncherServiceProvider)
                    .launchExternal(ExternalLinks.prayerRequests);
              },
            ),
          ],
        ),
      ),
    );
  }
}
