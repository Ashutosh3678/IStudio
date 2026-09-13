enum InvoiceStatus { paid, due, draft }

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.clientName,
    required this.amount,
    required this.issuedOn,
    required this.status,
  });

  final String id;
  final String number;
  final String clientName;
  final double amount;
  final DateTime issuedOn;
  final InvoiceStatus status;
}
