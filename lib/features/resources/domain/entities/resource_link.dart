/// What a Resources row shows as its icon; the presentation layer maps it
/// to a glyph.
enum ResourceKind {
  bulletin,
  prayerRequest,
  donate,
  church,
  news,
  bible,
  readings,
  video,
  podcast,
  children,
  prayers,
  saints,
  renewal,
  reflections,
}

/// A tab in the app's bottom navigation that a resource can switch to.
enum AppTab { news, donate }

/// Where tapping a Resources row goes.
sealed class ResourceDestination {
  const ResourceDestination();
}

/// A web page or document, opened in the device's browser.
final class WebDestination extends ResourceDestination {
  const WebDestination(this.url);

  final String url;
}

/// One of the app's own tabs.
final class AppTabDestination extends ResourceDestination {
  const AppTabDestination(this.tab);

  final AppTab tab;
}

/// The current month's Daily Readings & Reflections, found when tapped
/// (see `MonthlyReflection`).
final class DailyReflectionsDestination extends ResourceDestination {
  const DailyReflectionsDestination();
}

/// One row on the Resources page.
class ResourceLink {
  const ResourceLink({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.destination,
  });

  final String title;

  /// A short line under the title, e.g. the website's name.
  final String subtitle;
  final ResourceKind kind;
  final ResourceDestination destination;
}

/// A titled group of [ResourceLink]s, e.g. "Bible & Liturgy".
class ResourceGroup {
  const ResourceGroup({
    required this.title,
    this.subtitle,
    required this.links,
  });

  final String title;

  /// Optional small caption under the title.
  final String? subtitle;
  final List<ResourceLink> links;
}
