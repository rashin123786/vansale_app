import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/customer_entity.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final DioClient _dioClient;
  final ConnectivityService _connectivity;

  CustomerRepository(this._dioClient, this._connectivity);

  Future<List<CustomerEntity>> getCustomers({
    required String routeId,
    required String storeId,
  }) async {
    if (!await _connectivity.isConnected()) throw const NetworkFailure();
    try {
      final res = await _dioClient.dio.get(
        '/get_customer',
        queryParameters: {'route_id': routeId, 'store_id': storeId},
      );

      // API may return list directly or wrapped in data key
      final raw = res.data;
      List<dynamic> list = [];

      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list = raw['data'] ?? raw['customers'] ?? [];
      }

      return list.map((e) => CustomerModel.fromJson(e).toEntity()).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load customers');
    }
  }
}
