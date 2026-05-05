part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  final List<CustomerEntity> filtered;
  CustomerLoaded({required this.customers, required this.filtered});

  @override
  List<Object?> get props => [customers, filtered];
}

class CustomerError extends CustomerState {
  final String message;
  final bool isNetwork;
  CustomerError(this.message, {this.isNetwork = false});

  @override
  List<Object?> get props => [message, isNetwork];
}
