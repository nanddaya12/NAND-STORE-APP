import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final double rating;
  final int reviewsCount;
  final String category;
  final String icon;
  final String badge;
  final Map<String, String> specs;
  final List<String> finishes;
  final Map<String, double> storageOptions;
  final List<String> images;
  final int stock;
  final List<String> sizes;
  final String? videoUrl; // Optional product video URL
  final String sellerId; // Associated seller/shop ID

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice = 0.0,
    required this.rating,
    this.reviewsCount = 0,
    required this.category,
    required this.icon,
    this.badge = '',
    required this.specs,
    this.finishes = const [],
    this.storageOptions = const {},
    this.images = const [],
    this.stock = 15,
    this.sizes = const [],
    this.videoUrl,
    this.sellerId = 's1', // Default to s1 (NAND Tech Emporium)
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    double? rating,
    int? reviewsCount,
    String? category,
    String? icon,
    String? badge,
    Map<String, String>? specs,
    List<String>? finishes,
    Map<String, double>? storageOptions,
    List<String>? images,
    int? stock,
    List<String>? sizes,
    String? videoUrl,
    String? sellerId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      badge: badge ?? this.badge,
      specs: specs ?? this.specs,
      finishes: finishes ?? this.finishes,
      storageOptions: storageOptions ?? this.storageOptions,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes,
      videoUrl: videoUrl ?? this.videoUrl,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        oldPrice,
        rating,
        reviewsCount,
        category,
        icon,
        badge,
        specs,
        finishes,
        storageOptions,
        images,
        stock,
        sizes,
        videoUrl,
        sellerId,
      ];
}
