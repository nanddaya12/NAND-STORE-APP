import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.oldPrice = 0.0,
    required super.rating,
    super.reviewsCount = 0,
    required super.category,
    required super.icon,
    super.badge = '',
    required super.specs,
    super.finishes = const [],
    super.storageOptions = const {},
    super.images = const [],
    super.stock = 15,
    super.sizes = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      category: json['category'] as String,
      icon: json['icon'] as String,
      badge: json['badge'] as String? ?? '',
      specs: Map<String, String>.from(json['specs'] as Map? ?? const {}),
      finishes: List<String>.from(json['finishes'] ?? const []),
      storageOptions: Map<String, double>.from(
        (json['storageOptions'] as Map? ?? const {}).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      images: List<String>.from(json['images'] ?? const []),
      stock: json['stock'] as int? ?? 15,
      sizes: List<String>.from(json['sizes'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'category': category,
      'icon': icon,
      'badge': badge,
      'specs': specs,
      'finishes': finishes,
      'storageOptions': storageOptions,
      'images': images,
      'stock': stock,
      'sizes': sizes,
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      oldPrice: entity.oldPrice,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      category: entity.category,
      icon: entity.icon,
      badge: entity.badge,
      specs: entity.specs,
      finishes: entity.finishes,
      storageOptions: entity.storageOptions,
      images: entity.images,
      stock: entity.stock,
      sizes: entity.sizes,
    );
  }
}
