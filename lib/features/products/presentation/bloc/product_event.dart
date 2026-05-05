part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String storeId;
  LoadProducts(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);
  @override
  List<Object?> get props => [query];
}
