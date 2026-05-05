class UserEntity {
  final String userId;
  final String name;
  final String email;
  final String storeId;
  final String storeName;
  final String routeId;
  final String vanId;
  final String token;

  const UserEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.storeId,
    required this.storeName,
    required this.routeId,
    required this.vanId,
    required this.token,
  });
}
