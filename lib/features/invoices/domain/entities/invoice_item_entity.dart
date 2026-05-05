import '../../../products/domain/entities/product_entity.dart';

class InvoiceItemEntity {
  final ProductEntity product;
  final int quantity;

  const InvoiceItemEntity({required this.product, required this.quantity});

  double get subtotal => product.basePrice * quantity;

  InvoiceItemEntity copyWith({int? quantity}) =>
      InvoiceItemEntity(product: product, quantity: quantity ?? this.quantity);
}
