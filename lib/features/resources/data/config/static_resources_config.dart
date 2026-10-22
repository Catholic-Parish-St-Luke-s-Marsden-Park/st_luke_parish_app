import '../../domain/entities/resource_link.dart';

/// The Resources page's groups and links, from the parish web app's
/// "Catholic Resources" page (parish request, 2026-10-16). Faith Formation
/// has its own menu item (see [faithFormationGroups]). The Parish Resources
/// group (Bulletins, Prayer Requests, Donate) was removed: each already has
/// its own tab or menu item (parish request, 2026-10-22).
const List<ResourceGroup> resourceGroups = [
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
        title: 'Bible',
        subtitle: 'biblegateway.com',
        kind: ResourceKind.bible,
        destination: WebDestination('https://www.biblegateway.com/'),
      ),
      ResourceLink(
        title: 'Daily Mass Readings',
        subtitle: 'bible.usccb.org',
        kind: ResourceKind.readings,
        destination: WebDestination('https://bible.usccb.org'),
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
