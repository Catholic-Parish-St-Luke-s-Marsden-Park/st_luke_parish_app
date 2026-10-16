import '../../domain/entities/contact_item.dart';

/// Ported verbatim from the sibling reference app (`st_luke_frontend_app`,
/// `lib/features/contact/data/static_contact_data.dart`).
const String parishAddress = '55a Frontier Avenue, Marsden Park NSW 2765';
const String parishMapsQuery = '55a+Frontier+Avenue,+Marsden+Park+NSW+2765';

/// Static, in-code (non-scraped) configuration for the Contact tab: exactly
/// 8 entries, in this order, per the approved BA plan.
const List<ContactItem> staticContactItems = [
  ContactItem(
    icon: '📞',
    label: 'Phone',
    value: '(02) 7261 0246',
    action: ContactAction.call,
    actionTarget: 'tel:0272610246',
  ),
  ContactItem(
    icon: '📱',
    label: 'Mobile',
    value: '0422 724 160',
    action: ContactAction.call,
    actionTarget: 'tel:0422724160',
  ),
  ContactItem(
    icon: '✉️',
    label: 'Email',
    value: 'marsdenpark@parracatholic.org',
    action: ContactAction.email,
    actionTarget: 'mailto:marsdenpark@parracatholic.org',
  ),
  ContactItem(
    icon: '📍',
    label: 'Church Address',
    value: '55a Frontier Ave, Marsden Park NSW 2765',
    subtitle: 'Cnr Frontier Ave & Northbourne Dr',
    action: ContactAction.none,
  ),
  ContactItem(
    icon: '📬',
    label: 'Postal Address',
    value: 'PO Box 4045, Elara Village',
    subtitle: 'Marsden Park NSW 2765',
    action: ContactAction.none,
  ),
  ContactItem(
    icon: '🕐',
    label: 'Office Hours',
    value: 'Monday – Friday · 9:30am – 4:30pm',
    action: ContactAction.none,
  ),
  ContactItem(
    icon: '📘',
    label: 'Facebook',
    value: "St Luke's Catholic Parish Marsden Park",
    action: ContactAction.url,
    actionTarget: 'https://www.facebook.com/stlukesmarsdenpark/',
  ),
  ContactItem(
    icon: '🌐',
    label: 'Website',
    value: 'stlukesmarsdenpark.org.au',
    action: ContactAction.url,
    actionTarget: 'https://stlukesmarsdenpark.org.au',
  ),
];
