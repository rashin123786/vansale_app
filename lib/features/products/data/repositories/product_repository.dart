import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DioClient _dioClient;
  final ConnectivityService _connectivity;

  ProductRepository(this._dioClient, this._connectivity);

  Future<List<ProductEntity>> getProducts({required String storeId}) async {
    if (!await _connectivity.isConnected()) throw const NetworkFailure();
    try {
      final res = await _dioClient.dio.get(
        '/get_product',
        queryParameters: {'store_id': storeId},
      );

      // Parse using the wrapper that handles:
      // { "data": { "data": [...products], "current_page": 1 }, "success": true }
      final response = ProductListResponse.fromJson(
        res.data as Map<String, dynamic>,
      );

      return response.products.map((m) => m.toEntity()).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load products');
    }
  }
}
