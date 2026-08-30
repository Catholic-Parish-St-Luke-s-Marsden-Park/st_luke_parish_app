import '../../domain/entities/announcement.dart';

/// Static "Parish News" content (REQ-F05-023..025), sourced from the
/// user-reviewed HTML mockup referenced by the approved BA plan
/// (`.claude/plans/ba/2026-08-30_19-06-05-news-tab.md`). Exactly 2 entries —
/// the reference app's third "Sacramental Programme 2026" entry is
/// intentionally dropped.
const List<Announcement> staticAnnouncements = [
  Announcement(
    badge: 'Milestone',
    title: 'New Parish Building Now Open',
    body:
        'Our purpose-built parish building was opened and blessed on the '
        'Feast of St Luke in October 2025. All Masses and parish events are '
        'now held at the corner of Frontier Avenue and Northbourne Drive.',
    date: 'October 2025',
  ),
  Announcement(
    badge: 'New to the area?',
    title: 'New to Marsden Park?',
    body:
        "If you've recently moved to Marsden Park, Elara, Colebee or "
        'surrounds, email us at marsdenpark@parracatholic.org with your '
        'name and contact details to stay updated.',
    date: 'Ongoing',
  ),
];
