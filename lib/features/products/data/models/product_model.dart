import '../../domain/entities/product_entity.dart';

class ProductUnitModel {
  final int unitId;
  final String name;
  final double price;
  final double? minPrice;
  final int stock;

  const ProductUnitModel({
    required this.unitId,
    required this.name,
    required this.price,
    this.minPrice,
    required this.stock,
  });

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      unitId: json['id'] as int? ?? json['unit'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      minPrice: json['min_price'] != null
          ? double.tryParse(json['min_price'].toString())
          : null,
      stock: json['stock'] as int? ?? 0,
    );
  }

  ProductUnitEntity toEntity() => ProductUnitEntity(
    unitId: unitId,
    name: name,
    price: price,
    minPrice: minPrice,
    stock: stock,
  );
}

class ProductModel {
  final int id;
  final String? code;
  final String name;
  final String proImage;
  final double taxPercentage;
  final double basePrice;
  final int storeId;
  final int status;
  final List<ProductUnitModel> units;

  const ProductModel({
    required this.id,
    this.code,
    required this.name,
    required this.proImage,
    required this.taxPercentage,
    required this.basePrice,
    required this.storeId,
    required this.status,
    required this.units,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'];
    final unitList = rawUnits is List
        ? rawUnits
              .map((u) => ProductUnitModel.fromJson(u as Map<String, dynamic>))
              .toList()
        : <ProductUnitModel>[];

    return ProductModel(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString(),
      name: json['name']?.toString() ?? 'Unknown Product',
      proImage: json['pro_image']?.toString() ?? 'default.jpg',
      taxPercentage:
          double.tryParse(json['tax_percentage']?.toString() ?? '0') ?? 0,
      basePrice: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      status: json['status'] as int? ?? 1,
      units: unitList,
    );
  }

  ProductEntity toEntity() => ProductEntity(
    id: id,
    code: code,
    name: name,
    proImage: proImage,
    taxPercentage: taxPercentage,
    basePrice: basePrice,
    storeId: storeId,
    status: status,
    units: units.map((u) => u.toEntity()).toList(),
  );
}

// ── API response wrapper (handles pagination) ──
class ProductListResponse {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;

  const ProductListResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    // Response shape: { "data": { "data": [...], "current_page": 1 }, "success": true }
    final outer = json['data'];
    final pagination = outer is Map<String, dynamic>
        ? outer
        : <String, dynamic>{};
    final rawList = pagination['data'];
    final list = rawList is List
        ? rawList
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : <ProductModel>[];

    return ProductListResponse(
      products: list,
      currentPage: pagination['current_page'] as int? ?? 1,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? list.length,
    );
  }
}
