import '../../domain/entities/ask_luke_topic.dart';

/// Static, hardcoded topic -> response mapping for the Ask Luke quick-reply
/// screen. This is placeholder copy (confirmed by the user) with no real
/// backend/AI behind it in this phase; exact response strings per the
/// approved BA plan.
///
/// Order matters — chips render in this exact order.
const List<AskLukeTopic> askLukeTopics = [
  AskLukeTopic(
    label: 'Mass times',
    // Must match the Masses tab's "What's On" schedule
    // (lib/features/masses/data/config/static_mass_schedule_config.dart);
    // ask_luke_screen_test.dart fails if a time or note there is missing.
    response:
        'Saturday Vigil Mass: 5:30 PM '
        '(Reconciliation from 4:30–5:25pm).\n'
        'Sunday Mass Times: 8:00 AM, 10:00 AM and 5:30 PM. '
        'Marsden Park Care Community: 10:00 AM, 4th Sunday of the month: '
        'Liturgy of the Word with Holy Communion.\n'
        'Weekday: Wednesday 7:30 AM, Thursday 9:00 AM and Friday 6:30 PM '
        '(1st Friday of the month: Healing Mass & Benediction, with the '
        'Anointing of the Sick).\n'
        'Marsden Park Care Community Mass: Friday 11:00 AM, '
        '2nd Friday of the month.\n'
        'Times may vary on public holidays — please check the parish '
        'bulletin for the latest schedule.',
  ),
  AskLukeTopic(
    label: 'Join a ministry',
    response:
        "St Luke's has many ministries you can get involved in, from music "
        'and hospitality to youth and outreach. Contact the parish office '
        'and our team will help you find the right fit.',
  ),
  AskLukeTopic(
    label: 'Baptism',
    response:
        "We'd love to welcome your child into our parish family through "
        'Baptism. Please contact the parish office to arrange a '
        'preparation session and booking.',
  ),
  AskLukeTopic(
    label: 'Sacraments',
    response:
        "St Luke's celebrates the Sacraments of Baptism, First Holy "
        'Communion, Reconciliation, Confirmation, Marriage and Anointing '
        'of the Sick. Contact the parish office for more information on '
        'preparation and scheduling.',
  ),
];
