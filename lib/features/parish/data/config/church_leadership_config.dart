import '../../domain/entities/church_leadership_entry.dart';
import '../../domain/entities/church_leadership_section.dart';

/// Static, in-code (non-scraped) configuration for the Parish tab's 3-part
/// "Church Leadership" section: Universal Church, Diocese of Parramatta,
/// Parish (2 rows: Parish Priest, Parish Secretary).
///
/// This content is not scraped from `stlukesmarsdenpark.org.au` — it is
/// static typed config per the approved BA plan. Deacon Tony Hoban is
/// intentionally excluded (confirmed dropped by the user).
const List<ChurchLeadershipSection> churchLeadershipSections = [
  ChurchLeadershipSection(
    title: 'Universal Church',
    entries: [
      ChurchLeadershipEntry(
        name: 'Pope Leo XIV',
        role: 'Bishop of Rome',
        assetPath: 'assets/images/leadership/pope_leo_xiv.jpeg',
        linkUrl: 'https://www.vaticannews.va/en.html',
      ),
    ],
  ),
  ChurchLeadershipSection(
    title: 'Diocese of Parramatta',
    entries: [
      ChurchLeadershipEntry(
        name: 'Bishop Vincent Long',
        role: 'Bishop of Parramatta',
        assetPath: 'assets/images/leadership/diocese_of_parramatta.jpg',
        linkUrl: 'https://parracatholic.org',
      ),
    ],
  ),
  ChurchLeadershipSection(
    title: 'Parish',
    entries: [
      ChurchLeadershipEntry(
        name: 'Fr Gayan Thamel',
        role: 'Parish Priest',
        assetPath: 'assets/images/leadership/fr_gayan_thamel.png',
        linkUrl: 'https://stlukesmarsdenpark.org.au',
      ),
      ChurchLeadershipEntry(
        name: 'Gerald "Ged" Oblea',
        role: 'Parish Secretary',
        assetPath: 'assets/images/leadership/ged_oblea.jpg',
        // No link — confirmed by user, not tappable for navigation.
      ),
    ],
  ),
];
