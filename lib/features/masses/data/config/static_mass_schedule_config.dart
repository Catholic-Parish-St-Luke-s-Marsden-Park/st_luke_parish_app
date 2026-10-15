import '../../domain/entities/mass_schedule.dart';
import '../../domain/entities/mass_sub_group.dart';
import '../../domain/entities/mass_time.dart';
import '../../domain/entities/mass_times_card.dart';
import '../../domain/entities/parish_activity.dart';

/// Static, in-code (non-scraped) configuration for the Masses tab, sourced
/// from the user-reviewed HTML mockup referenced by the approved BA plan
/// (`.claude/plans/ba/2026-08-30_11-22-04-masses-tab.md`) and updated from
/// the parish bulletin's "Regular Activities" panel (2026-10-15). This is a
/// static local data source, not a scraper — it lives under `data/` so it
/// can later be swapped for a scraped/remote source without restructuring.
///
/// The Ask Luke "Mass times" answer must give the same times and notes as
/// [whatsOnCards]; `ask_luke_screen_test.dart` checks this.

const List<MassTime> saturdayVigilMasses = [
  MassTime(
    label: 'Time',
    time: '5:30 PM',
    note: 'Reconciliation from 4:30–5:25pm',
  ),
];

const List<MassTime> sundayMasses = [
  MassTime(label: 'Times', time: '8:00 AM, 10:00 AM and 5:30 PM'),
  MassTime(
    time: '10:00 AM',
    name: 'Marsden Park Care Community',
    note: '4th Sunday of the month: Liturgy of the Word with Holy Communion',
  ),
];

const List<MassTime> weekdayMasses = [
  MassTime(label: 'Wednesday', time: '7:30 AM'),
  MassTime(label: 'Thursday', time: '9:00 AM'),
  MassTime(
    label: 'Friday',
    time: '6:30 PM',
    note:
        '1st Friday of the month: Healing Mass & Benediction, with the '
        'Anointing of the Sick',
  ),
  MassTime(
    label: 'Friday',
    time: '11:00 AM',
    name: 'Marsden Park Care Community Mass',
    note: '2nd Friday of the month',
  ),
];

/// "What's On" section: a "Weekend Mass Times" card (Saturday Vigil first,
/// then Sunday) and a "Weekday Mass Times" card (parish request,
/// 2026-10-15).
const List<MassTimesCard> whatsOnCards = [
  MassTimesCard(
    title: 'Weekend Mass Times',
    subGroups: [
      MassSubGroup(label: 'Saturday Vigil Mass', rows: saturdayVigilMasses),
      MassSubGroup(label: 'Sunday Mass Times', rows: sundayMasses),
    ],
  ),
  MassTimesCard(
    title: 'Weekday Mass Times',
    subGroups: [MassSubGroup(label: 'Weekday', rows: weekdayMasses)],
  ),
];

const _parishEmail = 'marsdenpark@parracatholic.org';

/// "Regular Activities" section, in the bulletin's reading order, with each
/// entry's text split into when / where / who / description / contact.
/// One-off dates ("This weekend…", "Next session…") are deliberately left
/// out so the app doesn't go stale; the Parish Mass Times block is covered
/// by [whatsOnCards] instead.
const List<ParishActivity> regularActivities = [
  ParishActivity(
    title: 'Communion to the Sick & Housebound',
    kind: ParishActivityKind.communionToSick,
    where: 'In your home',
    description:
        'Our Pastoral Care Team is available to bring Holy Communion to '
        'parishioners who are sick or unable to attend Mass. If you or '
        'someone you know would like to receive Communion at home, please '
        'contact the Parish Office.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Reconciliation Times',
    kind: ParishActivityKind.reconciliation,
    when: 'Saturdays: 4.30pm to 5.25pm, or by appointment',
    where: 'Parish Office',
    description:
        'Experience God\'s mercy and forgiveness in the Sacrament of '
        'Reconciliation. Whether it has been a week or many years, you are '
        'always welcome.',
  ),
  ParishActivity(
    title: "Children's Liturgy",
    kind: ParishActivityKind.childrensLiturgy,
    when: 'During school term, at Saturday Vigil & Sunday Mass',
    who: 'Ages 5-10',
    description:
        'Children are invited out during Mass to hear and explore the '
        'Sunday readings in a way they can understand, through stories, '
        'discussion and activities. They return to their families before '
        'the Liturgy of the Eucharist.',
  ),
  ParishActivity(
    title: 'Baptisms',
    kind: ParishActivityKind.baptism,
    when: 'Every 1st, 3rd and 4th Sunday of the month',
    description:
        'Booking & preparation are essential. Contact the Parish Office to '
        'register.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Marriages',
    kind: ParishActivityKind.marriage,
    when: 'Strictly by appointment',
    description:
        'Congratulations on your engagement! We would love to help you '
        'prepare for the Sacrament of Marriage. A minimum of 6 months '
        'notice is required.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Sacramental Process',
    kind: ParishActivityKind.sacraments,
    description:
        'First Reconciliation, First Eucharist, Confirmation, and OCIA - '
        'Order of Christian Initiation for Adults.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Youth Ministry',
    kind: ParishActivityKind.youth,
    when: 'Every 2nd Friday: 6.30pm Mass, then the youth program at 7pm',
    where: "St Luke's Hub",
    who: 'Students in Year 4 to Year 12',
    description:
        'A welcoming space for young people to grow in faith, build '
        'friendships and have fun together. Each evening includes games, '
        'discussion and prayer.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'SRE-Scripture Program',
    kind: ParishActivityKind.scripture,
    when: 'Every Tuesday during school term',
    where: 'Public schools',
    description:
        'Special Religious Education brings the Gospel to Catholic students '
        'in local public schools. Volunteers required: no experience is '
        'needed, and training and support are provided.',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Parish Cuppa',
    kind: ParishActivityKind.cuppa,
    when: 'Every 2nd weekend',
    where: 'After Mass',
    description:
        'Stay after Mass for a cup of tea or coffee and a chat. It is a '
        'great way to meet fellow parishioners and welcome newcomers to '
        'our parish family. Everyone is welcome!',
  ),
  ParishActivity(
    title: 'Weekend Food Stall',
    kind: ParishActivityKind.foodStall,
    when: 'Weekends',
    description:
        'Stop by the food stall after Mass and enjoy something delicious '
        'with family and friends. Proceeds of this fundraising activity '
        'goes towards the parish building fund.',
  ),
  ParishActivity(
    title: 'Prayer Ministry',
    kind: ParishActivityKind.prayer,
    when: '1st weekend, every 2nd month',
    where: 'After Mass',
    description:
        'Whether you need guidance, support, or simply someone to pray '
        'with, feel free to come forward after Mass and let us join you in '
        'prayer.',
  ),
  ParishActivity(
    title: 'Marsden Park Care Community Mass',
    kind: ParishActivityKind.careCommunity,
    when:
        '2nd Friday of each month at 11am: Mass\n'
        '4th Sunday of each month at 10am: Liturgy of the Word with Holy '
        'Communion',
    where: 'Marsden Park Care Community',
    description:
        'Our parish brings the Mass and Holy Communion to the residents of '
        'the Marsden Park Care Community. Family members and parishioners '
        'are welcome to join in.',
  ),
  ParishActivity(
    title: 'Rosary Block',
    kind: ParishActivityKind.rosary,
    when:
        'Take the statue home after the Sunday 10am Mass and return it '
        'before the Saturday 5.30pm Mass',
    where: 'Your home',
    description:
        'Welcome the statue of Our Lady of Fatima to your home. Register '
        'your interest on the roster on the information tables outside the '
        'performance hub.',
  ),
  ParishActivity(
    title: 'Walking with Christ',
    kind: ParishActivityKind.faithGroup,
    when: 'Fortnightly on Thursdays at 7.00pm',
    where: 'Parish Office',
    description:
        'Looking for space to grow in faith, explore Scripture, and walk '
        'with others in our parish community? Come and join us!',
    contact: _parishEmail,
  ),
  ParishActivity(
    title: 'Diocese of Parramatta',
    kind: ParishActivityKind.safeguarding,
    description:
        'The Diocese of Parramatta is committed to synodality where all '
        'people, including adults at risk are involved in discussions and '
        'communications about safeguarding practices to ensure we are a '
        'humble and healing church.',
  ),
];

/// The full static schedule exposed to the UI via `massScheduleProvider`.
const MassSchedule staticMassSchedule = MassSchedule(
  whatsOnCards: whatsOnCards,
  regularActivities: regularActivities,
);
