import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/van_sale_entity.dart';
import '../models/van_sale_model.dart';

class InvoiceRepository {
  final DioClient _dioClient;
  final ConnectivityService _connectivity;

  InvoiceRepository(this._dioClient, this._connectivity);

  /// Create a van sale invoice
  /// Matches API: POST /vansale.store
  Future<bool> createVanSale({
    required int customerId,
    required int storeId,
    required int userId,
    required int vanId,
    required double discount,
    required double total,
    required double totalTax,
    required double grandTotal,
    required String remarks,
    required List<int> itemIds,
    required List<int> quantities,
    required List<double> mrpList,
    required List<int> productTypes,
    required List<int> unitIds,
  }) async {
    if (!await _connectivity.isConnected()) throw const NetworkFailure();
    try {
      final res = await _dioClient.dio.post(
        '/vansale.store',
        data: {
          'customer_id': customerId,
          'store_id': storeId,
          'user_id': userId,
          'van_id': vanId,
          'save_mode': 'normal',
          'order_type': 1,
          'discount': discount,
          'total': total,
          'total_tax': totalTax,
          'grand_total': grandTotal,
          'round_off': 0,
          'if_vat': 1,
          'remarks': remarks,
          'item_id': itemIds,
          'quantity': quantities,
          'mrp': mrpList,
          'product_type': productTypes,
          'unit': unitIds,
        },
      );

      // API returns success if status 200 or success key
      final data = res.data;
      if (data is Map) {
        return data['success'] == true ||
            data['status'] == 'success' ||
            res.statusCode == 200;
      }
      return res.statusCode == 200 || res.statusCode == 201;
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to create invoice');
    }
  }

  /// Fetch van sale list
  /// GET /vansale.index
  Future<List<VanSaleEntity>> getVanSaleList({
    required String userId,
    required String storeId,
    required String vanId,
  }) async {
    print('Fetching invoices for user: $userId, store: $storeId, van: $vanId');
    if (!await _connectivity.isConnected()) throw const NetworkFailure();
    try {
      final res = await _dioClient.dio.get(
        '/vansale.index',
        queryParameters: {'user_id': "150", 'store_id': "112", 'van_id': "0"},
      );
      print('Raw invoice response: ${res.data}');
      final raw = res.data;
      List<dynamic> list = [];

      if (raw is Map) {
        if (raw['data'] is Map) {
          list = raw['data']['data'] ?? []; // ✅ correct
        } else if (raw['data'] is List) {
          list = raw['data'];
        }
      }

      return list.map((e) => VanSaleModel.fromJson(e).toEntity()).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load invoices');
    }
  }
}
