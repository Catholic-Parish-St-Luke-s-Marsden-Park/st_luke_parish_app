import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/external_links.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../data/config/static_resources_config.dart';
import '../../domain/entities/resource_link.dart';
import '../providers/reflections_provider.dart';
import '../widgets/resource_group_card.dart';
import '../widgets/resource_link_tile.dart';

/// A drawer page of grouped links — Resources or Faith Formation — from
/// the parish web app's "Catholic Resources". Web links open in the
/// device's browser; Bulletins and Donate switch to the app's own tabs via
/// [onOpenTab].
class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({
    super.key,
    this.title = 'Resources',
    this.groups = resourceGroups,
    required this.onOpenTab,
  });

  /// Shown in the app bar.
  final String title;
  final List<ResourceGroup> groups;

  /// Called for a link to one of the app's tabs; the host closes this page
  /// and selects that tab.
  final ValueChanged<AppTab> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflection = switch (ref.watch(latestReflectionProvider)) {
      AsyncData(:final value) => value,
      // Still loading, or the page couldn't be read: the button opens the
      // page listing every month instead.
      _ => null,
    };
    final launcher = ref.read(urlLauncherServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          for (final group in groups)
            ResourceGroupCard(
              group: group,
              rowBuilder: (link) => switch (link.destination) {
                WebDestination(:final url) => ResourceLinkTile(
                  link: link,
                  onTap: () => launcher.launchExternal(url),
                ),
                AppTabDestination(:final tab) => ResourceLinkTile(
                  link: link,
                  onTap: () => onOpenTab(tab),
                ),
                DailyReflectionsDestination() => ResourceLinkTile(
                  link: link,
                  // e.g. "On Our Knees (October 2026 Edition)", following
                  // the month of the booklet found.
                  title: reflection == null
                      ? null
                      : '${link.title} (${reflection.label} Edition)',
                  onTap: () => launcher.launchExternal(
                    reflection?.url ?? ExternalLinks.dailyReflectionsPage,
                  ),
                ),
              },
            ),
        ],
      ),
    );
  }
}
