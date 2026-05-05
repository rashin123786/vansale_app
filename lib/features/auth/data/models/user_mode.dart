import '../../domain/entities/user_entity.dart';

class LoginResponseModel {
  final String token;
  final String userId;

  const LoginResponseModel({required this.token, required this.userId});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // API returns token + user info on login
    final data = json['data'] ?? json;
    return LoginResponseModel(
      token: data['token']?.toString() ?? json['token']?.toString() ?? '',
      userId:
          data['user_id']?.toString() ??
          data['id']?.toString() ??
          json['user_id']?.toString() ??
          '',
    );
  }
}

class UserDetailModel {
  final String userId;
  final String name;
  final String email;
  final String storeId;
  final String storeName;
  final String routeId;
  final String vanId;

  const UserDetailModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.storeId,
    required this.storeName,
    required this.routeId,
    required this.vanId,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct and nested response
    final data = json['data'] ?? json;
    final user = data is List ? (data.isNotEmpty ? data[0] : {}) : data;

    return UserDetailModel(
      userId: user['id']?.toString() ?? user['user_id']?.toString() ?? '',
      name: user['name']?.toString() ?? user['username']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      storeId: user['store_id']?.toString() ?? '112',
      storeName: user['store_name']?.toString() ?? '',
      routeId: user['route_id']?.toString() ?? '84',
      vanId: user['van_id']?.toString() ?? '0',
    );
  }

  UserEntity toEntity(String token) => UserEntity(
    userId: userId,
    name: name,
    email: email,
    storeId: storeId,
    storeName: storeName,
    routeId: routeId,
    vanId: vanId,
    token: token,
  );
}
