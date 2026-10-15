import '../../domain/entities/announcement.dart';

/// Static "Parish News" content (REQ-F05-023..025), sourced from the
/// user-reviewed HTML mockup referenced by the approved BA plan
/// (`.claude/plans/ba/2026-08-30_19-06-05-news-tab.md`). The reference
/// app's third "Sacramental Programme 2026" entry is intentionally dropped,
/// and "New to Marsden Park?" moved to the Parish tab (parish request,
/// 2026-10-16).
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
];
