import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/app_storage.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_mode.dart';

class AuthRepository {
  final DioClient _dioClient;
  final ConnectivityService _connectivity;
  final AppStorage _storage;

  AuthRepository(this._dioClient, this._connectivity, this._storage);

  Future<UserEntity> login(String email, String password) async {
    if (!await _connectivity.isConnected()) throw const NetworkFailure();

    try {
      // Step 1 — Login to get token + user_id
      final loginRes = await _dioClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final loginData = LoginResponseModel.fromJson(loginRes.data);

      // if (loginData.token.isEmpty) {
      //   throw const AuthFailure('Invalid credentials. Please try again.');
      // }

      // Save token immediately so next call has auth header
      await _storage.saveToken(loginData.userId);

      // Step 2 — Fetch user detail
      final userId = loginData.userId.isNotEmpty ? loginData.userId : '150';
      final detailRes = await _dioClient.dio.get(
        '/get_user_detail',
        queryParameters: {'user_id': userId},
      );

      final userDetail = UserDetailModel.fromJson(detailRes.data);

      // Step 3 — Persist session data
      await _storage.saveUserSession(
        userId: userDetail.userId.isNotEmpty ? userDetail.userId : userId,
        storeId: userDetail.storeId,
        routeId: userDetail.routeId,
        vanId: userDetail.vanId,
      );

      return userDetail.toEntity(loginData.token);
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 422) {
        throw const AuthFailure('Invalid email or password.');
      }
      throw ServerFailure(e.message ?? 'Server error. Please try again.');
    }
  }

  Future<void> logout() async => _storage.clear();
}
