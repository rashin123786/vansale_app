import '../../domain/entities/van_sale_entity.dart';

class VanSaleModel {
  final String id;
  final String invoiceNo;
  final String customerName;
  final double total;
  final double grandTotal;
  final String date;
  final String status;

  const VanSaleModel({
    required this.id,
    required this.invoiceNo,
    required this.customerName,
    required this.total,
    required this.grandTotal,
    required this.date,
    required this.status,
  });

  factory VanSaleModel.fromJson(Map<String, dynamic> json) {
    return VanSaleModel(
      id: json['id']?.toString() ?? '',

      invoiceNo:
          json['invoice_no']?.toString() ??
          json['order_no']?.toString() ??
          '#${json['id']}',

      // ✅ FIX: customer is ARRAY
      customerName: (json['customer'] is List && json['customer'].isNotEmpty)
          ? json['customer'][0]['name']?.toString() ?? 'Customer'
          : 'Customer',

      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,

      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0,

      // ✅ FIX: combine date + time
      date: _parseDateTime(json),

      // ✅ FIX: status int → readable string
      status: json['status'] == 1 ? 'Completed' : 'Pending',
    );
  }

  VanSaleEntity toEntity() => VanSaleEntity(
    id: id,
    invoiceNo: invoiceNo,
    customerName: customerName,
    total: total,
    grandTotal: grandTotal,
    date: date,
    status: status,
  );
}

String _parseDateTime(Map<String, dynamic> json) {
  final date = json['in_date'];
  final time = json['in_time'];

  if (date != null && time != null) {
    return '$date $time'; // "2026-05-05 12:34:23"
  }

  return json['created_at']?.toString() ?? '';
}
