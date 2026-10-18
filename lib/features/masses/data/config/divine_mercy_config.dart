import '../../domain/entities/rosary_step.dart';

/// The Chaplet of Divine Mercy, prayed on rosary beads, following "How to
/// Recite the Chaplet" by the Marian Fathers of the Immaculate Conception
/// (https://thedivinemercy.org/message/devotions/pray-the-chaplet; parish
/// request, 2026-10-18). The longer optional prayers quoted there from St
/// Faustina's Diary are not reproduced; the page links to them.
const divineMercyPageUrl =
    'https://thedivinemercy.org/message/devotions/pray-the-chaplet';

/// The first Divine Mercy image, painted by Eugeniusz Kazimirowski in 1934
/// under St Faustina's direction (public domain, via Wikimedia Commons).
const divineMercyImage = 'assets/images/rosary/divine_mercy.jpg';
const divineMercyImageCaption =
    'The Divine Mercy, Eugeniusz Kazimirowski, Vilnius, 1934';

const divineMercyIntro =
    'The Chaplet of Divine Mercy is prayed on ordinary rosary beads. It was '
    'given by Jesus to St Faustina, and is especially prayed at 3 o\'clock, '
    'the Hour of Mercy.';

const divineMercySource =
    'Prayers as given by the Marian Fathers of the Immaculate Conception, '
    'thedivinemercy.org.';

const _signOfTheCross = RosaryPrayer(
  name: 'Sign of the Cross',
  text:
      'In the name of the Father, and of the Son, and of the Holy Spirit. '
      'Amen.',
);

const _openingPrayers = [
  RosaryPrayer(
    name: 'You expired, Jesus',
    text:
        'You expired, Jesus, but the source of life gushed forth for souls, '
        'and the ocean of mercy opened up for the whole world. O Fount of '
        'Life, unfathomable Divine Mercy, envelop the whole world and empty '
        'Yourself out upon us.',
  ),
  RosaryPrayer(
    name: 'O Blood and Water (repeat three times)',
    text:
        'O Blood and Water, which gushed forth from the Heart of Jesus as a '
        'fount of mercy for us, I trust in You!',
  ),
];

const _ourFather = RosaryPrayer(
  name: 'Our Father',
  text:
      'Our Father, Who art in Heaven, hallowed be Thy name; Thy kingdom come; '
      'Thy will be done on earth as it is in Heaven. Give us this day our '
      'daily bread; and forgive us our trespasses, as we forgive those who '
      'trespass against us; and lead us not into temptation, but deliver us '
      'from evil, Amen.',
);

const _hailMary = RosaryPrayer(
  name: 'Hail Mary',
  text:
      'Hail Mary, full of grace. The Lord is with thee. Blessed art thou '
      'amongst women, and blessed is the fruit of thy womb, Jesus. Holy Mary, '
      'Mother of God, pray for us sinners, now and at the hour of our death, '
      'Amen.',
);

const _apostlesCreed = RosaryPrayer(
  name: "The Apostles' Creed",
  text:
      'I believe in God, the Father almighty, Creator of Heaven and earth, '
      'and in Jesus Christ, His only Son, our Lord, who was conceived by the '
      'Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, '
      'was crucified, died and was buried; He descended into hell; on the '
      'third day He rose again from the dead; He ascended into Heaven, and '
      'is seated at the right hand of God the Father almighty; from there He '
      'will come to judge the living and the dead. I believe in the Holy '
      'Spirit, the holy Catholic Church, the Communion of Saints, the '
      'forgiveness of sins, the Resurrection of the body, and life '
      'everlasting. Amen.',
);

const _eternalFather = RosaryPrayer(
  name: 'The Eternal Father',
  text:
      'Eternal Father, I offer You the Body and Blood, Soul and Divinity of '
      'Your Dearly Beloved Son, Our Lord, Jesus Christ, in atonement for our '
      'sins and those of the whole world.',
);

const _forTheSake = RosaryPrayer(
  name: 'For the sake of His sorrowful Passion',
  text:
      'For the sake of His sorrowful Passion, have mercy on us and on the '
      'whole world.',
);

const _holyGod = RosaryPrayer(
  name: 'Holy God',
  text:
      'Holy God, Holy Mighty One, Holy Immortal One, have mercy on us and on '
      'the whole world.',
);

const _closingPrayer = RosaryPrayer(
  name: 'Closing Prayer',
  text:
      'Eternal God, in Whom mercy is endless and the treasury of compassion '
      'inexhaustible, look kindly upon us and increase Your mercy in us, that '
      'in difficult moments we might not despair nor become despondent, but '
      'with great confidence submit ourselves to Your holy will, which is '
      'Love and Mercy itself.',
);

const _ordinals = ['first', 'second', 'third', 'fourth', 'fifth'];

/// The whole Chaplet, one bead (one prayer) per step.
final List<RosaryStep> divineMercySteps = [
  const RosaryStep(
    instruction: 'Make the Sign of the Cross.',
    beads: RosaryBeads(RosaryBeadKind.crucifix),
    prayers: [_signOfTheCross],
  ),
  const RosaryStep(
    instruction: 'Optional opening prayers.',
    beads: RosaryBeads(RosaryBeadKind.crucifix),
    prayers: _openingPrayers,
    optional: true,
  ),
  const RosaryStep(
    instruction: 'Pray the "Our Father."',
    beads: RosaryBeads(RosaryBeadKind.firstOurFather),
    prayers: [_ourFather],
  ),
  const RosaryStep(
    instruction: 'Pray the "Hail Mary."',
    beads: RosaryBeads(RosaryBeadKind.introHailMary),
    prayers: [_hailMary],
  ),
  const RosaryStep(
    instruction: 'Pray the "Apostles\' Creed."',
    beads: RosaryBeads(RosaryBeadKind.introHailMary, bead: 1),
    prayers: [_apostlesCreed],
  ),
  for (var d = 0; d < 5; d++) ...[
    RosaryStep(
      instruction:
          'On the "Our Father" bead of the ${_ordinals[d]} decade, pray the '
          '"Eternal Father."',
      beads: RosaryBeads(RosaryBeadKind.decadeOurFather, decade: d),
      prayers: const [_eternalFather],
    ),
    for (var i = 0; i < 10; i++)
      RosaryStep(
        instruction: 'On each of the 10 small beads of the decade:',
        beads: RosaryBeads(RosaryBeadKind.decadeHailMary, decade: d, bead: i),
        prayers: const [_forTheSake],
        countLabel: 'Bead ${i + 1} of 10',
      ),
  ],
  for (var i = 0; i < 3; i++)
    RosaryStep(
      instruction: 'Conclude with "Holy God," three times.',
      beads: const RosaryBeads(RosaryBeadKind.centrepiece),
      prayers: const [_holyGod],
      countLabel: 'Holy God ${i + 1} of 3',
    ),
  const RosaryStep(
    instruction: 'Optional closing prayer.',
    beads: RosaryBeads(RosaryBeadKind.centrepiece),
    prayers: [_closingPrayer],
    optional: true,
  ),
];
