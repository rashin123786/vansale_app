import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String routeId;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.routeId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? json['customer_id']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['customer_name']?.toString() ??
          'Unknown',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? json['area']?.toString() ?? '',
      routeId: json['route_id']?.toString() ?? '',
    );
  }

  CustomerEntity toEntity() => CustomerEntity(
    id: id,
    name: name,
    phone: phone,
    address: address,
    routeId: routeId,
  );
}
