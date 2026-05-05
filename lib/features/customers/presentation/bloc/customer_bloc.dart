import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/entities/customer_entity.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc(this._repository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoad);
    on<SearchCustomers>(_onSearch);
  }

  Future<void> _onLoad(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await _repository.getCustomers(
        routeId: event.routeId,
        storeId: event.storeId,
      );
      emit(CustomerLoaded(customers: customers, filtered: customers));
    } on NetworkFailure catch (e) {
      emit(CustomerError(e.message, isNetwork: true));
    } on ServerFailure catch (e) {
      emit(CustomerError(e.message));
    } catch (_) {
      emit(CustomerError('Failed to load customers'));
    }
  }

  void _onSearch(SearchCustomers event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final all = (state as CustomerLoaded).customers;
      final q = event.query.toLowerCase();
      final filtered = q.isEmpty
          ? all
          : all
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(q) ||
                      c.phone.contains(q) ||
                      c.address.toLowerCase().contains(q),
                )
                .toList();
      emit(CustomerLoaded(customers: all, filtered: filtered));
    }
  }
}
