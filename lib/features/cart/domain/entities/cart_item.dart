import '../../../catalog/domain/entities/product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String selectedFinish;
  final String selectedStorage;
  final String selectedSize;
  final double addedCost;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedFinish = '',
    this.selectedStorage = '',
    this.selectedSize = '',
    this.addedCost = 0.0,
  });

  double get singleItemPrice => product.price + addedCost;
  double get totalItemPrice => singleItemPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedFinish,
    String? selectedStorage,
    String? selectedSize,
    double? addedCost,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedFinish: selectedFinish ?? this.selectedFinish,
      selectedStorage: selectedStorage ?? this.selectedStorage,
      selectedSize: selectedSize ?? this.selectedSize,
      addedCost: addedCost ?? this.addedCost,
    );
  }
}
