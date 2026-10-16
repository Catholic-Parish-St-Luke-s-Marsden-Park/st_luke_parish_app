import '../../domain/entities/bank_transfer_details.dart';
import '../../domain/entities/giving_area.dart';

/// The Donate tab's content, from the parish website's Donate page
/// (`https://stlukesmarsdenpark.org.au/donate/`, read 2026-10-16). Card
/// payments open BPOINT in the device's browser rather than inside the
/// app, so donors can see the bank's address bar and padlock, and so the
/// iOS app stays within Apple's rules for donations.
abstract final class DonateConfig {
  static const heading =
      'What a wonderful opportunity we have to grow as a Catholic parish, '
      'deepening our faith and supporting one another.';

  static const letter = [
    'Dear Friends,',
    "At St Luke's Catholic Parish, your generosity helps us not only in "
        'building our Parish but also in supporting the celebration of '
        'sacraments, pastoral care, and the many ministries that serve our '
        'people.',
    'Your support ensures that we can continue our mission of worship, '
        'service, and outreach. Please prayerfully consider how you can be '
        'part of this mission through your giving.',
    'Thank you for your generosity, and may God bless you abundantly.',
  ];

  /// The pull-down heading over [letter].
  static const messageTitle = 'Message from Fr Gayan';

  static const signedBy = 'Fr Gayan Thamel';
  static const signedByRole = 'Parish Priest';

  /// What a gift supports (parish-supplied wording, 2026-10-16).
  static const givingAreas = [
    GivingArea(
      title: 'Personnel & Staffing',
      kind: GivingAreaKind.staffing,
      description:
          'Salaries and health benefits for our priests and office staff.',
    ),
    GivingArea(
      title: 'Facilities & Operations',
      kind: GivingAreaKind.facilities,
      description:
          'Everyday utility bills (heating, cooling, electricity), council '
          'rates, insurance, and standard upkeep for our parish building '
          'and grounds.',
    ),
    GivingArea(
      title: 'Sacramental & Altar Supplies',
      kind: GivingAreaKind.sacramental,
      description:
          'Essential items for Mass and holy sacraments, including altar '
          'bread, wine, candles, vestments, missalettes, and copyright '
          'licences.',
    ),
    GivingArea(
      title: 'Faith Formation & Education',
      kind: GivingAreaKind.formation,
      description:
          "Workbooks, materials, and resources for children's religious "
          'education (CCD/PREP), Youth Ministry, and Adult Faith Formation '
          '(OCIA).',
    ),
    GivingArea(
      title: 'Community Outreach & Charity',
      kind: GivingAreaKind.outreach,
      description:
          'Direct support for our local food pantry, emergency assistance '
          'for families in crisis, and our mandatory contribution to broader '
          'diocesan ministries.',
    ),
    GivingArea(
      title: 'Capital Improvements (Building Fund)',
      kind: GivingAreaKind.buildingFund,
      description:
          // St Luke's has no permanent church yet (parish request,
          // 2026-10-16).
          "Saving towards building St Luke's first permanent church, as "
          'well as major, unavoidable repairs and improvements to our parish '
          'building and grounds.',
    ),
  ];

  /// Payments the same options can be used for, from the website.
  static const alsoPayFor =
      'You can also use these options to pay for Mass intentions, Baptisms, '
      'First Reconciliation, First Holy Communion and Confirmation.';

  /// The Commonwealth Bank BPOINT payment page linked from the website.
  static const bpointUrl = 'https://www.bpoint.com.au/pay/CATHOLICPARISH1';

  static const bankTransfer = BankTransferDetails(
    accountName: "Marsden Park St Luke's Parish",
    bsb: '067 950',
    accountNumber: '100005720',
    reference: 'Your name',
  );

  static const refundEmail = 'marsdenpark@parracatholic.org';

  static const refundPolicy =
      'Please contact our office by email at $refundEmail with any refund '
      'requests. Approved refunds will be credited back to the card used '
      'for the original transaction.';
}
