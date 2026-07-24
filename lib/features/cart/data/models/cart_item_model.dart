import '../../domain/entities/cart_item.dart';
import '../../../catalog/data/models/product_model.dart';

class CartItemModel extends CartItem {
  final ProductModel productModel;

  CartItemModel({
    required this.productModel,
    super.quantity = 1,
    super.selectedFinish = '',
    super.selectedStorage = '',
    super.selectedSize = '',
    super.addedCost = 0.0,
  }) : super(product: productModel);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productModel: ProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      quantity: json['quantity'] as int? ?? 1,
      selectedFinish: json['selectedFinish'] as String? ?? '',
      selectedStorage: json['selectedStorage'] as String? ?? '',
      selectedSize: json['selectedSize'] as String? ?? '',
      addedCost: (json['addedCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productModel.toJson(),
      'quantity': quantity,
      'selectedFinish': selectedFinish,
      'selectedStorage': selectedStorage,
      'selectedSize': selectedSize,
      'addedCost': addedCost,
    };
  }

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      productModel: ProductModel.fromEntity(entity.product),
      quantity: entity.quantity,
      selectedFinish: entity.selectedFinish,
      selectedStorage: entity.selectedStorage,
      selectedSize: entity.selectedSize,
      addedCost: entity.addedCost,
    );
  }
}
