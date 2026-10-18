import '../../domain/entities/rosary_mystery.dart';
import '../../domain/entities/rosary_step.dart';

/// "Pray the Rosary" and the prayers of the Rosary, word for word
/// from the Holy Rosary card by Mary's Rosary Chain Inc. (parish request,
/// 2026-10-18).
const rosaryHowToIntro =
    'It is customary to recite five decades at a time while meditating on '
    'one set of Mysteries. A decade is one "Our Father" followed by ten '
    '"Hail Marys" and one "Glory be".';

const _signOfTheCross = RosaryPrayer(
  name: 'Sign of the Cross',
  text:
      'In the name of the Father, and of the Son, and of the Holy Spirit. '
      'Amen.',
);

const _apostlesCreed = RosaryPrayer(
  name: "Apostles' Creed",
  text:
      'I believe in God, the Father almighty, Creator of heaven and earth, '
      'and in Jesus Christ, His only Son, Our Lord, who was conceived by the '
      'Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, '
      'was crucified, died and was buried; He descended into hell; on the '
      'third day He rose again from the dead; He ascended into heaven, and '
      'is seated at the right hand of God the Father almighty; from there He '
      'will come to judge the living and the dead. I believe in the Holy '
      'Spirit, the holy Catholic Church, the communion of saints, the '
      'forgiveness of sins, the resurrection of the body and life '
      'everlasting. Amen.',
);

const _ourFather = RosaryPrayer(
  name: 'Our Father',
  text:
      'Our Father, who art in heaven; hallowed be Thy Name; Thy kingdom '
      'come; Thy will be done on earth as it is in heaven. Give us this day '
      'our daily bread; and forgive us our trespasses as we forgive those '
      'who trespass against us, and lead us not into temptation; but '
      'deliver us from evil. Amen.',
);

const _hailMary = RosaryPrayer(
  name: 'Hail Mary',
  text:
      'Hail Mary, full of grace, the Lord is with thee, blessed art thou '
      'among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, '
      'Mother of God, pray for us sinners, now and at the hour of our death. '
      'Amen.',
);

const _gloryBe = RosaryPrayer(
  name: 'Glory be to the Father',
  text:
      'Glory be to the Father, and to the Son, and to the Holy Spirit. As it '
      'was in the beginning, is now, and ever shall be, world without end. '
      'Amen.',
);

const _fatimaPrayer = RosaryPrayer(
  name: 'Fatima Prayer',
  text:
      'O my Jesus, forgive us our sins, save us from the fires of hell. Lead '
      'all souls to Heaven, especially those in most need of Thy mercy.',
);

const _hailHolyQueen = RosaryPrayer(
  name: 'Hail, Holy Queen',
  text:
      'Hail, Holy Queen, Mother of Mercy, hail our life, our sweetness, and '
      'our hope. To thee do we cry, poor banished children of Eve; to thee '
      'do we send up our sighs, mourning and weeping in this valley of '
      'tears. Turn then, O most gracious Advocate, thine eyes of mercy '
      'towards us and after this our exile, show unto us the blessed fruit '
      'of thy womb, Jesus; O clement, O loving, O sweet Virgin Mary. Pray '
      'for us, O Holy Mother of God. That we may be made worthy of the '
      'promises of Christ.',
);

const _memorare = RosaryPrayer(
  name: 'Memorare',
  text:
      'Remember, O most gracious Virgin Mary, that never was it known, that '
      'anyone who fled to thy protection, implored thy help or sought thy '
      'intercession, was left unaided. Inspired with this confidence, I fly '
      'unto thee, O Virgin of virgins, my Mother. To thee do I come, before '
      'thee I stand, sinful and sorrowful. O Mother of the Word Incarnate, '
      'despise not my petitions, but in thy mercy hear and answer me. Amen.',
);

const _stMichael = RosaryPrayer(
  name: 'Prayer to St. Michael',
  text:
      'Saint Michael the Archangel, defend us in the day of battle. Be our '
      'safeguard against the wickedness and snares of the devil. May God '
      'rebuke him we humbly pray, and do thou, O Prince of the Heavenly '
      'Hosts, by the power of God, cast into hell satan and all the evil '
      'spirits, who wander through the world seeking the ruin of souls.',
);

const _letUsPray = RosaryPrayer(
  name: 'Let us Pray',
  text:
      'O God, whose only-begotten Son, by his life, death and resurrection '
      'has purchased for us the rewards of eternal life; grant, we beseech '
      'Thee, that meditating upon these Mysteries in the Most holy Rosary of '
      'the Blessed Virgin Mary, we may both imitate what they contain and '
      'obtain what they promise, through the same Christ Our Lord. Amen.',
);

const _ordinals = ['First', 'Second', 'Third', 'Fourth', 'Fifth'];

/// The whole Rosary, one bead (one prayer) per step, following the card's
/// "How to Pray the Rosary" with [set]'s Mysteries in their decades: the
/// opening prayers, then for each of the five decades the Mystery and Our
/// Father, ten Hail Marys, and the Glory Be and Fatima Prayer, then the
/// Hail, Holy Queen, and the card's two optional prayers after the Rosary:
/// the Memorare and the Prayer to St Michael.
List<RosaryStep> rosaryStepsFor(RosaryMysterySet set) => [
  const RosaryStep(
    instruction:
        'Make the "Sign of the Cross" and pray the "Apostles\' Creed."',
    beads: RosaryBeads(RosaryBeadKind.crucifix),
    prayers: [_signOfTheCross, _apostlesCreed],
  ),
  const RosaryStep(
    instruction: 'Pray the "Our Father."',
    beads: RosaryBeads(RosaryBeadKind.firstOurFather),
    prayers: [_ourFather],
  ),
  for (var i = 0; i < 3; i++)
    RosaryStep(
      instruction: 'Pray a "Hail Mary."',
      beads: RosaryBeads(RosaryBeadKind.introHailMary, bead: i),
      prayers: const [_hailMary],
    ),
  const RosaryStep(
    instruction: 'Pray the "Glory be to the Father."',
    beads: RosaryBeads(RosaryBeadKind.gloryBeforeDecades),
    prayers: [_gloryBe],
  ),
  for (final (d, mystery) in set.mysteries.indexed) ...[
    RosaryStep(
      instruction:
          'Announce the ${_ordinals[d]} Mystery, then pray the "Our '
          'Father."',
      beads: RosaryBeads(RosaryBeadKind.decadeOurFather, decade: d),
      prayers: const [_ourFather],
      mystery: mystery,
    ),
    for (var i = 0; i < 10; i++)
      RosaryStep(
        instruction: 'Pray a "Hail Mary," while meditating on the Mystery.',
        beads: RosaryBeads(RosaryBeadKind.decadeHailMary, decade: d, bead: i),
        prayers: const [_hailMary],
        mystery: mystery,
      ),
    RosaryStep(
      instruction:
          'Pray the "Glory be to the Father" and the "Fatima Prayer," '
          'requested by the Blessed Virgin Mary at Fatima.',
      beads: RosaryBeads(RosaryBeadKind.afterDecade, decade: d),
      prayers: const [_gloryBe, _fatimaPrayer],
    ),
  ],
  const RosaryStep(
    instruction:
        'Pray the "Hail, Holy Queen" after the five decades are completed '
        'and conclude with the "Sign of the Cross."',
    beads: RosaryBeads(RosaryBeadKind.centrepiece),
    prayers: [_hailHolyQueen, _letUsPray, _signOfTheCross],
  ),
  // From the card: "very powerful optional prayers recited after the Holy
  // Rosary".
  const RosaryStep(
    instruction:
        'After the Holy Rosary you may also pray the "Memorare," a very '
        'powerful prayer.',
    beads: RosaryBeads(RosaryBeadKind.centrepiece),
    prayers: [_memorare],
    optional: true,
  ),
  const RosaryStep(
    instruction:
        'You may also pray the "Prayer to St Michael the Archangel," a very '
        'powerful prayer.',
    beads: RosaryBeads(RosaryBeadKind.centrepiece),
    prayers: [_stMichael],
    optional: true,
  ),
];
