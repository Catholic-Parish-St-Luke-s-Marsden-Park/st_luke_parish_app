import '../../domain/entities/bank_transfer_details.dart';

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

  static const signedBy = 'Fr Gayan Thamel';
  static const signedByRole = 'Parish Priest';

  /// What a gift or payment can be for.
  static const givingFor = [
    'Building Fund',
    'Mass intentions',
    'Baptisms',
    'First Reconciliation',
    'First Holy Communion',
    'Confirmation',
    'Ongoing parish needs',
  ];

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
