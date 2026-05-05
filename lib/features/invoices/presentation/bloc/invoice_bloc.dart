import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/entities/van_sale_entity.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _repository;

  InvoiceBloc(this._repository) : super(const InvoiceState()) {
    on<SelectCustomer>(_onSelectCustomer);
    on<AddProduct>(_onAddProduct);
    on<RemoveProduct>(_onRemoveProduct);
    on<IncrementQty>(_onIncrement);
    on<DecrementQty>(_onDecrement);
    on<UpdateDiscount>(_onDiscount);
    on<UpdateRemarks>(_onRemarks);
    on<SubmitInvoice>(_onSubmit);
    on<ClearInvoice>(_onClear);
  }

  void _onSelectCustomer(SelectCustomer e, Emitter<InvoiceState> emit) {
    emit(state.copyWith(customer: e.customer, clearError: true));
  }

  void _onAddProduct(AddProduct e, Emitter<InvoiceState> emit) {
    final items = List<InvoiceItemEntity>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == e.product.id);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(InvoiceItemEntity(product: e.product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void _onRemoveProduct(RemoveProduct e, Emitter<InvoiceState> emit) {
    final items = state.items
        .where((i) => i.product.id != e.productId)
        .toList();
    emit(state.copyWith(items: items));
  }

  void _onIncrement(IncrementQty e, Emitter<InvoiceState> emit) {
    final items = state.items.map((item) {
      if (item.product.id == e.productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: items));
  }

  void _onDecrement(DecrementQty e, Emitter<InvoiceState> emit) {
    final items = state.items.map((item) {
      if (item.product.id == e.productId && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: items));
  }

  void _onDiscount(UpdateDiscount e, Emitter<InvoiceState> emit) {
    emit(state.copyWith(discount: e.discount));
  }

  void _onRemarks(UpdateRemarks e, Emitter<InvoiceState> emit) {
    emit(state.copyWith(remarks: e.remarks));
  }

  Future<void> _onSubmit(SubmitInvoice e, Emitter<InvoiceState> emit) async {
    if (state.customer == null || state.items.isEmpty) return;

    emit(state.copyWith(status: InvoiceStatus.submitting, clearError: true));
    try {
      await _repository.createVanSale(
        customerId: int.parse(state.customer!.id),
        storeId: int.parse(e.storeId),
        userId: int.parse(e.userId),
        vanId: int.parse(e.vanId),
        discount: state.discount,
        total: state.subtotal,
        totalTax: state.taxAmount,
        grandTotal: state.grandTotal,
        remarks: state.remarks.isEmpty ? 'Van Sale' : state.remarks,
        itemIds: state.items
            .map((i) => int.parse(i.product.id.toString()))
            .toList(),
        quantities: state.items.map((i) => i.quantity).toList(),
        mrpList: [state.items.first.product.basePrice],
        productTypes: [1],

        unitIds: [state.items.first.product.units.first.unitId],
      );
      emit(state.copyWith(status: InvoiceStatus.success));
    } on NetworkFailure catch (ex) {
      emit(
        state.copyWith(
          status: InvoiceStatus.failure,
          errorMessage: ex.message,
          isNetwork: true,
        ),
      );
    } on ServerFailure catch (ex) {
      emit(
        state.copyWith(status: InvoiceStatus.failure, errorMessage: ex.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: InvoiceStatus.failure,
          errorMessage: 'Failed to create invoice. Please try again.',
        ),
      );
    }
  }

  void _onClear(ClearInvoice e, Emitter<InvoiceState> emit) {
    emit(const InvoiceState());
  }
}

//-------------------------------
class InvoiceListBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  final InvoiceRepository _repository;

  InvoiceListBloc(this._repository) : super(InvoiceListInitial()) {
    on<LoadInvoiceList>(_onLoad);
  }

  Future<void> _onLoad(
    LoadInvoiceList e,
    Emitter<InvoiceListState> emit,
  ) async {
    emit(InvoiceListLoading());
    try {
      final list = await _repository.getVanSaleList(
        userId: e.userId,
        storeId: e.storeId,
        vanId: e.vanId,
      );
      emit(InvoiceListLoaded(list));
    } on NetworkFailure catch (ex) {
      emit(InvoiceListError(ex.message, isNetwork: true));
    } on ServerFailure catch (ex) {
      emit(InvoiceListError(ex.message));
    } catch (_) {
      emit(InvoiceListError('Failed to load invoices'));
    }
  }
}
