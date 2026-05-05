part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final List<ProductEntity> filtered;
  ProductLoaded({required this.products, required this.filtered});

  @override
  List<Object?> get props => [products, filtered];
}

class ProductError extends ProductState {
  final String message;
  final bool isNetwork;
  ProductError(this.message, {this.isNetwork = false});

  @override
  List<Object?> get props => [message, isNetwork];
}
