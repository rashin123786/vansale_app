part of 'invoice_bloc.dart';

abstract class InvoiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectCustomer extends InvoiceEvent {
  final CustomerEntity customer;
  SelectCustomer(this.customer);
  @override
  List<Object?> get props => [customer];
}

class AddProduct extends InvoiceEvent {
  final ProductEntity product;
  AddProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class RemoveProduct extends InvoiceEvent {
  final String productId;
  RemoveProduct(this.productId);
  @override
  List<Object?> get props => [productId];
}

class IncrementQty extends InvoiceEvent {
  final String productId;
  IncrementQty(this.productId);
  @override
  List<Object?> get props => [productId];
}

class DecrementQty extends InvoiceEvent {
  final String productId;
  DecrementQty(this.productId);
  @override
  List<Object?> get props => [productId];
}

class UpdateDiscount extends InvoiceEvent {
  final double discount;
  UpdateDiscount(this.discount);
  @override
  List<Object?> get props => [discount];
}

class UpdateRemarks extends InvoiceEvent {
  final String remarks;
  UpdateRemarks(this.remarks);
  @override
  List<Object?> get props => [remarks];
}

class SubmitInvoice extends InvoiceEvent {
  final String userId;
  final String storeId;
  final String vanId;
  SubmitInvoice({
    required this.userId,
    required this.storeId,
    required this.vanId,
  });
  @override
  List<Object?> get props => [userId, storeId, vanId];
}

class ClearInvoice extends InvoiceEvent {}
// ─────────────────────────────────────────────
//  Invoice List

abstract class InvoiceListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInvoiceList extends InvoiceListEvent {
  final String userId;
  final String storeId;
  final String vanId;
  LoadInvoiceList({
    required this.userId,
    required this.storeId,
    required this.vanId,
  });
  @override
  List<Object?> get props => [userId, storeId, vanId];
}
