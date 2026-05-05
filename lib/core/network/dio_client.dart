// ─────────────────────────────────────────────
//  core/network/dio_client.dart
// ─────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'app_storage.dart';

class DioClient {
  static const String baseUrl = 'http://142.93.214.133:3641/api';

  late final Dio dio;
  final AppStorage _storage;

  DioClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Log request (remove in production)
          // ignore: avoid_print
          print('→ ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('← ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (DioException e, handler) {
          // ignore: avoid_print
          print(
            '✗ ${e.response?.statusCode} ${e.requestOptions.path}: ${e.message}',
          );
          handler.next(e);
        },
      ),
    );
  }
}
