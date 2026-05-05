class ProductUnitEntity {
  final int unitId;
  final String name;
  final double price;
  final double? minPrice;
  final int stock;

  const ProductUnitEntity({
    required this.unitId,
    required this.name,
    required this.price,
    this.minPrice,
    required this.stock,
  });
}

class ProductEntity {
  final int id;
  final String? code;
  final String name;
  final String proImage;
  final double taxPercentage;
  final double basePrice; // top-level "price" field
  final int storeId;
  final int status;
  final List<ProductUnitEntity> units;

  const ProductEntity({
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

  bool get isActive => status == 1;

  /// First unit is default
  ProductUnitEntity? get defaultUnit => units.isNotEmpty ? units.first : null;
}
