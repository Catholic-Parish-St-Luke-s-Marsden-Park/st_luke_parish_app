import '../../domain/entities/rosary_mystery.dart';

/// Where the Mysteries text comes from: the Holy Rosary card published by
/// Mary's Rosary Chain Inc., St Marys South NSW (parish request, 2026-10-18).
/// The text below follows the card word for word, and each mystery's
/// picture is cut from the card.
const rosaryMysteriesSource =
    "Mysteries, Scripture, fruits and pictures from the Holy Rosary card by "
    "Mary's Rosary Chain Inc. Imprimatur: Most Rev. Bishop Terence Brady, "
    'DD, VG, 29 June 2009.';

/// From the card: when the sets are optionally prayed on Sundays.
const rosaryMysteriesSeasonNote =
    'As a general rule, depending on the season, the Joyful Mysteries are '
    'prayed on Monday and Saturday and optional on Sundays during Advent and '
    'the Christmas Season. The Sorrowful Mysteries are prayed on Tuesday and '
    'Friday and optional on Sundays during Lent. The Glorious Mysteries on '
    'Wednesday and Sunday and the Luminous Mysteries prayed on Thursday.';

/// The four sets of the Mysteries of the Rosary, in the card's order.
const List<RosaryMysterySet> rosaryMysterySets = [
  RosaryMysterySet(
    kind: RosaryMysteryKind.joyful,
    name: 'The Joyful Mysteries',
    daysLabel: 'Prayed on Monday & Saturday',
    weekdays: [DateTime.monday, DateTime.saturday],
    mysteries: [
      RosaryMystery(
        title: 'The Annunciation',
        verse:
            '"Do not be afraid, Mary, for you have found favour with God. And '
            'behold, you will conceive in your womb and bear a Son, and you '
            'shall call His name Jesus."',
        reference: 'Luke 1: 30 - 31',
        fruit: 'Humility',
        imageAsset: 'assets/images/rosary/joyful_1.jpg',
      ),
      RosaryMystery(
        title: 'The Visitation',
        verse:
            '"Blessed are you among women, and blessed is the fruit of your '
            'womb! And why is this granted to me, that the mother of my Lord '
            'should come to me?"',
        reference: 'Luke 1: 42 - 43',
        fruit: 'Love of Neighbour',
        imageAsset: 'assets/images/rosary/joyful_2.jpg',
      ),
      RosaryMystery(
        title: 'The Birth of Jesus',
        verse:
            'Mary gave birth to her first-born Son and wrapped Him in '
            'swaddling clothes, and laid Him in a manger, because there was '
            'no room for them in the inn.',
        reference: 'Luke 2: 7',
        fruit: 'Poverty',
        imageAsset: 'assets/images/rosary/joyful_3.jpg',
      ),
      RosaryMystery(
        title: 'The Presentation',
        verse:
            'And when the days of her purification were fulfilled according '
            'to the Law of Moses, they took Him up to Jerusalem to present '
            'Him to the Lord -',
        reference: 'Luke 2: 22 - 23',
        fruit: 'Obedience',
        imageAsset: 'assets/images/rosary/joyful_4.jpg',
      ),
      RosaryMystery(
        title: 'The Finding of the Child Jesus in the Temple',
        verse:
            'And it came to pass after three days, that they found Him in the '
            'temple, sitting in the midst of the teachers, both listening to '
            'them and asking them questions.',
        reference: 'Luke 2: 46',
        fruit: 'Joy in Finding Jesus',
        imageAsset: 'assets/images/rosary/joyful_5.jpg',
      ),
    ],
  ),
  RosaryMysterySet(
    kind: RosaryMysteryKind.luminous,
    name: 'The Luminous Mysteries',
    daysLabel: 'Prayed on Thursday',
    weekdays: [DateTime.thursday],
    mysteries: [
      RosaryMystery(
        title: "Christ's Baptism in the Jordan River",
        verse:
            'The Spirit descended like a dove on Him. And a voice came from '
            'heaven, "You are my Son, the Beloved; and with You I am well '
            'pleased."',
        reference: 'Mark 1: 10',
        fruit: 'Openness to the Holy Spirit',
        imageAsset: 'assets/images/rosary/luminous_1.jpg',
      ),
      RosaryMystery(
        title: "Christ's Self-revelation at the Marriage at Cana",
        verse:
            'Jesus changed water into wine, the first of His signs, and '
            'revealed His glory; and His disciples believed in Him.',
        reference: 'John 2: 11',
        fruit: 'To Jesus Through Mary',
        imageAsset: 'assets/images/rosary/luminous_2.jpg',
      ),
      RosaryMystery(
        title:
            "Christ's Proclamation of the Kingdom of God with His call to "
            'Conversion',
        verse:
            '"The time is fulfilled, and the kingdom of God has come near; '
            'repent, and believe in the good news."',
        reference: 'Mark 1: 15',
        fruit: 'Repentance and Trust in God',
        imageAsset: 'assets/images/rosary/luminous_3.jpg',
      ),
      RosaryMystery(
        title: "Christ's Transfiguration",
        verse:
            'And He was transfigured before them, and His face shone like the '
            'sun, and His clothes became dazzling white.',
        reference: 'Matthew 17: 2',
        fruit: 'Desire for Holiness',
        imageAsset: 'assets/images/rosary/luminous_4.jpg',
      ),
      RosaryMystery(
        title: "Christ's institution of the Eucharist",
        verse:
            'He took bread, gave thanks, broke it and gave it to them, '
            'saying, "This is my body, which is given for you. Do this in '
            'remembrance of me."',
        reference: 'Luke 22: 19',
        fruit: 'Adoration',
        imageAsset: 'assets/images/rosary/luminous_5.jpg',
      ),
    ],
  ),
  RosaryMysterySet(
    kind: RosaryMysteryKind.sorrowful,
    name: 'The Sorrowful Mysteries',
    daysLabel: 'Prayed on Tuesday & Friday',
    weekdays: [DateTime.tuesday, DateTime.friday],
    mysteries: [
      RosaryMystery(
        title: 'The Agony in the Garden',
        verse:
            'And His sweat became as drops of blood running down upon the '
            'ground. And rising from prayer He came to the disciples, and '
            'found them sleeping.',
        reference: 'Luke 22: 44 - 45',
        fruit: 'Sorrow for Sin',
        imageAsset: 'assets/images/rosary/sorrowful_1.jpg',
      ),
      RosaryMystery(
        title: 'The Scourging',
        verse:
            'Pilate, wishing to satisfy the crowd, released for them '
            'Barabbas; and having scourged Jesus, he delivered Him to be '
            'crucified.',
        reference: 'Mark 15: 15',
        fruit: 'Purity',
        imageAsset: 'assets/images/rosary/sorrowful_2.jpg',
      ),
      RosaryMystery(
        title: 'The Crowning with Thorns',
        verse:
            'And they stripped Him and put on Him a scarlet cloak; and '
            'plaiting a crown of thorns they put it on His head, and a reed '
            'into His right hand:',
        reference: 'Matthew 27: 28 - 29',
        fruit: 'Courage',
        imageAsset: 'assets/images/rosary/sorrowful_3.jpg',
      ),
      RosaryMystery(
        title: 'The Carrying of the Cross',
        verse:
            'They took Jesus, and He went out, bearing His own cross, to the '
            'place of the skull, which is called in Hebrew, Golgotha.',
        reference: 'John 19: 17',
        fruit: 'Patience',
        imageAsset: 'assets/images/rosary/sorrowful_4.jpg',
      ),
      RosaryMystery(
        title: 'The Crucifixion',
        verse:
            'Jesus, crying with a loud voice, said, "Father, into Your hands '
            'I commit My spirit!" And having said this He breathed His Last.',
        reference: 'Luke 23: 46',
        fruit: 'Perseverance',
        imageAsset: 'assets/images/rosary/sorrowful_5.jpg',
      ),
    ],
  ),
  RosaryMysterySet(
    kind: RosaryMysteryKind.glorious,
    name: 'The Glorious Mysteries',
    daysLabel: 'Prayed on Wednesday & Sunday',
    weekdays: [DateTime.wednesday, DateTime.sunday],
    mysteries: [
      RosaryMystery(
        title: 'The Resurrection',
        verse:
            '"Do not be afraid; for I know that you seek Jesus who was '
            'crucified. He is not here; for He has risen, as He said."',
        reference: 'Matthew 28: 5 - 6',
        fruit: 'Faith',
        imageAsset: 'assets/images/rosary/glorious_1.jpg',
      ),
      RosaryMystery(
        title: 'The Ascension',
        verse:
            'So then the Lord, after He had spoken to them, was taken up into '
            'heaven, and sits at the right hand of God.',
        reference: 'Mark 16: 19',
        fruit: 'Hope',
        imageAsset: 'assets/images/rosary/glorious_2.jpg',
      ),
      RosaryMystery(
        title: 'The Descent of the Holy Spirit',
        verse:
            'And they were all filled with the Holy Spirit and began to speak '
            'in foreign tongues, even as the Holy Spirit prompted them to '
            'speak.',
        reference: 'Acts 2: 4',
        fruit: 'Love of God',
        imageAsset: 'assets/images/rosary/glorious_3.jpg',
      ),
      RosaryMystery(
        title: 'The Assumption',
        verse:
            'Since we believe that Jesus died and rose again, even so, '
            'through Jesus, God will bring with Him those who have fallen '
            'asleep... and so we shall always be with the Lord.',
        reference: '1 Thessalonians 4: 14 - 17',
        fruit: 'Grace of a Happy Death',
        imageAsset: 'assets/images/rosary/glorious_4.jpg',
      ),
      RosaryMystery(
        title: 'The Coronation',
        verse:
            'A great sign appeared in heaven, a woman clothed with the sun, '
            'with the moon under her feet, and on her head a crown of twelve '
            'stars.',
        reference: 'Revelation 12: 1',
        fruit: "Trust in Mary's Intercession",
        imageAsset: 'assets/images/rosary/glorious_5.jpg',
      ),
    ],
  ),
];
