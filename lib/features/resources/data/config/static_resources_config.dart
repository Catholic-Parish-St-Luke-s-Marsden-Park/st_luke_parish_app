import '../../../../core/constants/external_links.dart';
import '../../domain/entities/resource_link.dart';

/// The Resources page's groups and links, from the parish web app's
/// "Catholic Resources" page (parish request, 2026-10-16). Bulletins and
/// Donate switch to the app's own tabs rather than opening the website.
/// Faith Formation has its own menu item (see [faithFormationGroups]).
const List<ResourceGroup> resourceGroups = [
  ResourceGroup(
    title: 'Parish Resources',
    subtitle: "St Luke's",
    links: [
      ResourceLink(
        title: 'Weekly Bulletins',
        subtitle: 'On the News tab',
        kind: ResourceKind.bulletin,
        destination: AppTabDestination(AppTab.news),
      ),
      ResourceLink(
        title: 'Prayer Requests',
        subtitle: 'stlukesmarsdenpark.org.au',
        kind: ResourceKind.prayerRequest,
        destination: WebDestination(ExternalLinks.prayerRequests),
      ),
      ResourceLink(
        title: 'Donate Online',
        subtitle: 'On the Donate tab',
        kind: ResourceKind.donate,
        destination: AppTabDestination(AppTab.donate),
      ),
    ],
  ),
  ResourceGroup(
    // Renamed and trimmed to two links (parish request, 2026-10-16).
    title: 'Universal & Local Church',
    links: [
      ResourceLink(
        title: 'Vatican News',
        subtitle: 'vaticannews.va',
        kind: ResourceKind.news,
        destination: WebDestination('https://www.vaticannews.va/en.html'),
      ),
      ResourceLink(
        title: 'Catholic Church Australia',
        subtitle: 'catholic.org.au',
        kind: ResourceKind.church,
        destination: WebDestination('https://www.catholic.org.au'),
      ),
    ],
  ),
  ResourceGroup(
    // Was "Bible & Liturgy" (parish request, 2026-10-17).
    title: 'Scripture & Readings',
    links: [
      // Parish request, 2026-10-16: the USCCB link is now the daily
      // readings (replacing Universalis), plus Bible Gateway.
      ResourceLink(
        title: 'Daily Mass Readings',
        subtitle: 'bible.usccb.org',
        kind: ResourceKind.readings,
        destination: WebDestination('https://bible.usccb.org'),
      ),
      ResourceLink(
        title: 'Catholic Bible Readings',
        subtitle: 'biblegateway.com',
        kind: ResourceKind.bible,
        destination: WebDestination('https://www.biblegateway.com/'),
      ),
    ],
  ),
];

/// The Faith Formation page, its own item in the side menu (parish request,
/// 2026-10-16).
const List<ResourceGroup> faithFormationGroups = [
  ResourceGroup(
    title: 'Faith Formation',
    subtitle: 'Catholic Content',
    links: [
      ResourceLink(
        title: 'FORMED',
        subtitle: 'formed.org',
        kind: ResourceKind.video,
        destination: WebDestination('https://www.formed.org'),
      ),
      ResourceLink(
        title: 'Word on Fire',
        subtitle: 'wordonfire.org',
        kind: ResourceKind.podcast,
        destination: WebDestination('https://www.wordonfire.org'),
      ),
      ResourceLink(
        title: 'Catholic Prayers',
        subtitle: 'usccb.org',
        kind: ResourceKind.prayers,
        destination: WebDestination(
          'https://www.usccb.org/prayer-and-worship/prayers-and-devotions',
        ),
      ),
      ResourceLink(
        title: 'CHARIS',
        subtitle: 'Catholic Charismatic Renewal · charis.international',
        kind: ResourceKind.renewal,
        destination: WebDestination('https://www.charis.international/en/'),
      ),
      ResourceLink(
        title: 'On Our Knees',
        subtitle: 'Daily Reading & Reflections',
        kind: ResourceKind.reflections,
        destination: DailyReflectionsDestination(),
      ),
    ],
  ),
];
