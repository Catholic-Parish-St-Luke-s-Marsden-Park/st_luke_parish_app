import '../../domain/entities/rosary_step.dart';

/// "How to Pray the Rosary" and the prayers of the Rosary, word for word
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

const _letUsPray = RosaryPrayer(
  name: 'Let us Pray',
  text:
      'O God, whose only-begotten Son, by his life, death and resurrection '
      'has purchased for us the rewards of eternal life; grant, we beseech '
      'Thee, that meditating upon these Mysteries in the Most holy Rosary of '
      'the Blessed Virgin Mary, we may both imitate what they contain and '
      'obtain what they promise, through the same Christ Our Lord. Amen.',
);

/// The card's ten steps, each with the beads it is prayed on and its
/// prayers.
const List<RosaryStep> rosarySteps = [
  RosaryStep(
    instruction:
        'Make the "Sign of the Cross" and pray the "Apostles\' Creed."',
    beads: RosaryBeadGroup.crucifix,
    prayers: [_signOfTheCross, _apostlesCreed],
  ),
  RosaryStep(
    instruction: 'Pray the "Our Father."',
    beads: RosaryBeadGroup.firstOurFather,
    prayers: [_ourFather],
  ),
  RosaryStep(
    instruction: 'Pray three "Hail Marys."',
    beads: RosaryBeadGroup.threeHailMarys,
    prayers: [_hailMary],
  ),
  RosaryStep(
    instruction: 'Pray the "Glory be to the Father."',
    beads: RosaryBeadGroup.gloryBeforeFirstDecade,
    prayers: [_gloryBe],
  ),
  RosaryStep(
    instruction: 'Announce the First Mystery, then pray the "Our Father."',
    beads: RosaryBeadGroup.firstMysteryOurFather,
    prayers: [_ourFather],
    announcesMystery: true,
  ),
  RosaryStep(
    instruction: 'Pray ten "Hail Marys," while meditating on the Mystery.',
    beads: RosaryBeadGroup.firstDecade,
    prayers: [_hailMary],
  ),
  RosaryStep(
    instruction: 'Pray the "Glory be to the Father."',
    beads: RosaryBeadGroup.afterFirstDecade,
    prayers: [_gloryBe],
  ),
  RosaryStep(
    instruction:
        'After each decade pray the "Fatima Prayer," requested by the '
        'Blessed Virgin Mary at Fatima.',
    beads: RosaryBeadGroup.afterFirstDecade,
    prayers: [_fatimaPrayer],
  ),
  RosaryStep(
    instruction:
        'Announce the Second Mystery, then pray the "Our Father." Repeat '
        'steps 6, 7 and 8 and continue with the Third, Fourth and Fifth '
        'Mysteries in the same manner.',
    beads: RosaryBeadGroup.remainingDecades,
    prayers: [_ourFather],
    announcesMystery: true,
  ),
  RosaryStep(
    instruction:
        'Pray the "Hail, Holy Queen" after the five decades are completed '
        'and conclude with the "Sign of the Cross."',
    beads: RosaryBeadGroup.centrepiece,
    prayers: [_hailHolyQueen, _letUsPray, _signOfTheCross],
  ),
];
