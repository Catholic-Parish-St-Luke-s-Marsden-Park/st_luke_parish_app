/// The parish's account details for donations by bank transfer (EFT).
class BankTransferDetails {
  const BankTransferDetails({
    required this.accountName,
    required this.bsb,
    required this.accountNumber,
    required this.reference,
  });

  final String accountName;
  final String bsb;
  final String accountNumber;

  /// What donors should put as the payment reference.
  final String reference;
}
