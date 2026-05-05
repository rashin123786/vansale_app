import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/entities/product_entity.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoad);
    on<SearchProducts>(_onSearch);
  }

  Future<void> _onLoad(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getProducts(storeId: event.storeId);
      emit(ProductLoaded(products: products, filtered: products));
    } on NetworkFailure catch (e) {
      emit(ProductError(e.message, isNetwork: true));
    } on ServerFailure catch (e) {
      emit(ProductError(e.message));
    } catch (_) {
      emit(ProductError('Failed to load products'));
    }
  }

  void _onSearch(SearchProducts event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final all = (state as ProductLoaded).products;
      final q = event.query.toLowerCase().trim();
      final filtered = q.isEmpty
          ? all
          : all
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(q) ||
                      (p.code?.toLowerCase().contains(q) ?? false),
                )
                .toList();
      emit(ProductLoaded(products: all, filtered: filtered));
    }
  }
}
