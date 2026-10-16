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
            // Parish-supplied wording (2026-10-16).
            'Pope Leo XIV, born Robert Francis Prevost in Chicago, USA, was '
            'elected Pope in May 2025, becoming the first American to serve '
            'as Bishop of Rome. A member of the Order of St Augustine, he '
            'spent many years as a missionary and bishop in Peru before '
            'serving the Church in Rome. His experience as a missionary and '
            'pastor has shaped his emphasis on unity, peace and a Church that '
            'walks closely with people. As our Holy Father, Pope Leo XIV '
            'continues the mission entrusted to St Peter, strengthening '
            'Catholics throughout the world in faith and leading the Church '
            'in the way of Christ.',
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
            'Bishop Vincent Long OFM Conv was born in Vietnam and came to '
            'Australia as a refugee following the Vietnam War. His own '
            'journey of leaving his homeland and beginning a new life in '
            'Australia has deeply influenced his ministry and his concern for '
            'people on the margins. A Conventual Franciscan, Bishop Vincent '
            'was appointed Bishop of Parramatta in 2016. He is known for '
            'encouraging a Church that listens, welcomes and reaches out to '
            'others. As our Bishop, he leads the Diocese of Parramatta and '
            'accompanies its diverse communities in living and sharing the '
            'Gospel.',
        photoCredit: 'Photo: BaBaBa91 · CC BY-SA 4.0',
      ),
    ],
  ),
  ChurchLeadershipSection(
    title: 'Parish Team',
    entries: [
      ChurchLeadershipEntry(
        name: 'Fr Gayan Thamel',
        role: 'Parish Priest',
        assetPath: 'assets/images/leadership/fr_gayan_thamel.png',
        linkUrl: 'https://stlukesmarsdenpark.org.au',
        linkLabel: 'Visit the parish website',
        about:
            'Fr Gayan Thamel was born in Sri Lanka and ordained a priest in '
            'the Diocese of Bunbury, Western Australia, in 2002. He moved to '
            'the Diocese of Parramatta in 2018, serving in Windsor and '
            "Richmond before becoming the first parish priest of St Luke's "
            'Catholic Parish, Marsden Park, in 2025. Fr Gayan also serves as '
            'the Episcopal Vicar for Migrant Chaplaincies in the Diocese of '
            'Parramatta and as a Specialist Reserve Chaplain with the Royal '
            'Australian Air Force at RAAF Base Richmond. His varied '
            'experience of priestly ministry continues to shape his service '
            'of the Church and his desire to build a welcoming and '
            'faith-filled parish community.',
      ),
      ChurchLeadershipEntry(
        name: 'Gerald "Ged" Oblea',
        role: 'Parish Secretary',
        assetPath: 'assets/images/leadership/ged_oblea.jpg',
        linkUrl: 'mailto:marsdenpark@parracatholic.org',
        linkLabel: 'Email the parish office',
        about:
            'Gerald "Ged" Oblea was made in the Philippines and born in '
            'Australia. He and his wife Samantha are proud parents to '
            'Kayelani, Zane, Calen, Ethan and Gianna. Following marketing '
            'studies and over 13 years in retail product management, Ged '
            'embraced parish ministry. His 13 years of fulltime ministry '
            "include serving St Andrew's Marayong, Mary Immaculate Quakers "
            "Hill and Mary Queen of the Family Blacktown. Now at St Luke's, "
            'Ged shares his gifts to help continually attract people and '
            'nurture a community where everyone deepens their relationship '
            'with Jesus and experiences transformation in every area of life, '
            'growing together in faith, hope and love daily.',
      ),
    ],
  ),
];
