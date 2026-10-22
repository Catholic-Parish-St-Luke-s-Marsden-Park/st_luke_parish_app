import '../../domain/entities/litany_line.dart';
import '../../domain/entities/rosary_step.dart';

/// The Litany of the Blessed Virgin Mary, word for word from the Holy Rosary
/// card by Mary's Rosary Chain Inc. (parish request, 2026-10-18).
const litanyTitle = 'Litany of the Blessed Virgin Mary';

const _prayForUs = 'pray for us.';
const _haveMercy = 'have mercy on us.';
const _lambOfGod = 'Lamb of God, who takes away the sins of the world,';

const List<LitanyLine> litanyLines = [
  LitanyLine('Lord, have mercy.', 'Lord, have mercy.'),
  LitanyLine('Christ, have mercy.', 'Christ, have mercy.'),
  LitanyLine('Lord, have mercy.', 'Lord, have mercy.'),
  LitanyLine('Christ, hear us.', 'Christ, graciously hear us.'),
  LitanyLine('God the Father of Heaven,', _haveMercy),
  LitanyLine('God the Son, Redeemer of the world,', _haveMercy),
  LitanyLine('God the Holy Spirit,', _haveMercy),
  LitanyLine('Holy Trinity, One God,', _haveMercy),
  LitanyLine('Holy Mary,', _prayForUs),
  LitanyLine('Holy Mother of God,', _prayForUs),
  LitanyLine('Holy Virgin of virgins,', _prayForUs),
  LitanyLine('Mother of Christ,', _prayForUs),
  LitanyLine('Mother of the Church,', _prayForUs),
  LitanyLine('Mother of divine grace,', _prayForUs),
  LitanyLine('Mother most pure,', _prayForUs),
  LitanyLine('Mother most chaste,', _prayForUs),
  LitanyLine('Mother inviolate,', _prayForUs),
  LitanyLine('Mother undefiled,', _prayForUs),
  LitanyLine('Mother most amiable,', _prayForUs),
  LitanyLine('Mother most admirable,', _prayForUs),
  LitanyLine('Mother of good counsel,', _prayForUs),
  LitanyLine('Mother of Our Creator,', _prayForUs),
  LitanyLine('Mother of Our Saviour,', _prayForUs),
  LitanyLine('Virgin most prudent,', _prayForUs),
  LitanyLine('Virgin most venerable,', _prayForUs),
  LitanyLine('Virgin most renowned,', _prayForUs),
  LitanyLine('Virgin most powerful,', _prayForUs),
  LitanyLine('Virgin most merciful,', _prayForUs),
  LitanyLine('Virgin most faithful,', _prayForUs),
  LitanyLine('Mirror of justice,', _prayForUs),
  LitanyLine('Seat of wisdom,', _prayForUs),
  LitanyLine('Cause of our joy,', _prayForUs),
  LitanyLine('Spiritual vessel,', _prayForUs),
  LitanyLine('Vessel of honour,', _prayForUs),
  LitanyLine('Singular vessel of devotion,', _prayForUs),
  LitanyLine('Mystical rose,', _prayForUs),
  LitanyLine('Tower of David,', _prayForUs),
  LitanyLine('Tower of ivory,', _prayForUs),
  LitanyLine('House of gold,', _prayForUs),
  LitanyLine('Ark of the covenant,', _prayForUs),
  LitanyLine('Gate of Heaven,', _prayForUs),
  LitanyLine('Morning Star,', _prayForUs),
  LitanyLine('Health of the sick,', _prayForUs),
  LitanyLine('Refuge of sinners,', _prayForUs),
  LitanyLine('Comforter of the afflicted,', _prayForUs),
  LitanyLine('Help of Christians,', _prayForUs),
  LitanyLine('Queen of Angels,', _prayForUs),
  LitanyLine('Queen of Patriarchs,', _prayForUs),
  LitanyLine('Queen of Prophets,', _prayForUs),
  LitanyLine('Queen of Apostles,', _prayForUs),
  LitanyLine('Queen of Martyrs,', _prayForUs),
  LitanyLine('Queen of Confessors,', _prayForUs),
  LitanyLine('Queen of Virgins,', _prayForUs),
  LitanyLine('Queen of all Saints,', _prayForUs),
  LitanyLine('Queen conceived without original sin,', _prayForUs),
  LitanyLine('Queen assumed into Heaven,', _prayForUs),
  LitanyLine('Queen of the most holy Rosary,', _prayForUs),
  LitanyLine('Queen of families,', _prayForUs),
  LitanyLine('Queen of peace,', _prayForUs),
  LitanyLine(_lambOfGod, 'Spare us, O Lord.'),
  LitanyLine(_lambOfGod, 'Graciously hear us, O Lord.'),
  LitanyLine(_lambOfGod, 'Have mercy on us.'),
  LitanyLine(
    'V. Pray for us, O Holy Mother of God.',
    'R. That we may be made worthy of the promises of Christ.',
  ),
];

const litanyClosingPrayer = RosaryPrayer(
  name: 'Let us pray',
  text:
      'Grant, we beg you, O Lord God, that we your servants may enjoy lasting '
      'health of mind and body and by the glorious intercession of the '
      'Blessed Mary, ever Virgin, be delivered from present sorrow and enter '
      'into the joy of eternal happiness, through Christ Our Lord. Amen.',
);
