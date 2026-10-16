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
      // Photo and pull-down added at the parish's request (2026-10-16).
      ChurchLeadershipEntry(
        name: 'Pope Leo XIV',
        role: 'Bishop of Rome',
        assetPath: 'assets/images/leadership/pope_leo_xiv_portrait.jpg',
        linkUrl: 'https://www.vatican.va',
        linkLabel: 'Visit the Vatican website',
        about:
            'Pope Leo XIV (Robert Francis Prevost) was elected the 267th '
            'successor of St Peter on 8 May 2025. Born in Chicago, he is an '
            'Augustinian who served for many years as a missionary and '
            'bishop in Peru. Let us keep our Holy Father in our prayers.',
        photoCredit: 'Photo: Edgar Beltrán, The Pillar · CC BY-SA 4.0',
      ),
    ],
  ),
  ChurchLeadershipSection(
    title: 'Diocese of Parramatta',
    entries: [
      ChurchLeadershipEntry(
        name: 'Bishop Vincent Long',
        role: 'Bishop of Parramatta',
        assetPath: 'assets/images/leadership/bishop_vincent_long_portrait.jpg',
        linkUrl: 'https://parracatholic.org',
        linkLabel: 'Visit the Diocese of Parramatta',
        about:
            'Bishop Vincent Long Van Nguyen OFM Conv has shepherded the '
            "Diocese of Parramatta, to which St Luke's belongs, since 2016. "
            'Born in Vietnam, he came to Australia as a refugee and is a '
            'Conventual Franciscan friar. Let us pray for our Bishop.',
        photoCredit: 'Photo: BaBaBa91 · CC BY-SA 4.0',
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
