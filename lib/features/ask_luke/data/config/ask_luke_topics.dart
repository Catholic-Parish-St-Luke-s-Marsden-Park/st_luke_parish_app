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
    response:
        'Weekend Mass: Saturday 6:00pm (Vigil), Sunday 8:00am & 10:00am. '
        'Weekday Mass: Tuesday–Friday 9:00am. Times may vary on public '
        'holidays — please check the parish bulletin for the latest '
        'schedule.',
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
