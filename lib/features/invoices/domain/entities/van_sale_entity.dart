class VanSaleEntity {
  final String id;
  final String invoiceNo;
  final String customerName;
  final double total;
  final double grandTotal;
  final String date;
  final String status;

  const VanSaleEntity({
    required this.id,
    required this.invoiceNo,
    required this.customerName,
    required this.total,
    required this.grandTotal,
    required this.date,
    required this.status,
  });
}
