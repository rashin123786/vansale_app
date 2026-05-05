part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final String routeId;
  final String storeId;
  LoadCustomers({required this.routeId, required this.storeId});

  @override
  List<Object?> get props => [routeId, storeId];
}

class SearchCustomers extends CustomerEvent {
  final String query;
  SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}
