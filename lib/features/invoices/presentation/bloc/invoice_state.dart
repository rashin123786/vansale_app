part of 'invoice_bloc.dart';

enum InvoiceStatus { idle, submitting, success, failure }

class InvoiceState extends Equatable {
  final CustomerEntity? customer;
  final List<InvoiceItemEntity> items;
  final double discount;
  final String remarks;
  final InvoiceStatus status;
  final String? errorMessage;
  final bool isNetwork;

  const InvoiceState({
    this.customer,
    this.items = const [],
    this.discount = 0,
    this.remarks = '',
    this.status = InvoiceStatus.idle,
    this.errorMessage,
    this.isNetwork = false,
  });

  // ── Computed ───────────────────────────────
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxAmount => subtotal * 0.05; // 5% VAT
  double get grandTotal => subtotal + taxAmount - discount;
  int get totalItems => items.fold(0, (s, i) => s + i.quantity);

  InvoiceState copyWith({
    CustomerEntity? customer,
    List<InvoiceItemEntity>? items,
    double? discount,
    String? remarks,
    InvoiceStatus? status,
    String? errorMessage,
    bool? isNetwork,
    bool clearError = false,
    bool clearCustomer = false,
  }) {
    return InvoiceState(
      customer: clearCustomer ? null : (customer ?? this.customer),
      items: items ?? this.items,
      discount: discount ?? this.discount,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNetwork: isNetwork ?? this.isNetwork,
    );
  }

  @override
  List<Object?> get props => [
    customer,
    items,
    discount,
    remarks,
    status,
    errorMessage,
    isNetwork,
  ];
}

//-----------------------

abstract class InvoiceListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvoiceListInitial extends InvoiceListState {}

class InvoiceListLoading extends InvoiceListState {}

class InvoiceListLoaded extends InvoiceListState {
  final List<VanSaleEntity> sales;
  InvoiceListLoaded(this.sales);
  @override
  List<Object?> get props => [sales];
}

class InvoiceListError extends InvoiceListState {
  final String message;
  final bool isNetwork;
  InvoiceListError(this.message, {this.isNetwork = false});
  @override
  List<Object?> get props => [message, isNetwork];
}
