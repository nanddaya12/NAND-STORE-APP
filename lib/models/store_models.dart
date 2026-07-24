export '../features/catalog/domain/entities/product.dart';
export '../features/cart/domain/entities/cart_item.dart';
export '../features/notifications/domain/entities/notification.dart';
import '../features/catalog/domain/entities/product.dart';

class SellerReview {
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  const SellerReview({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class SellerProfile {
  final String id;
  final String name;
  final String shopName;
  final String email;
  final String phone;
  final String profileImage;
  final String bannerImage;
  final String description;
  final double rating;
  final List<SellerReview> reviews;

  const SellerProfile({
    required this.id,
    required this.name,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.bannerImage,
    required this.description,
    this.rating = 4.8,
    this.reviews = const [],
  });
}

const List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'X-1 Pro Headphones',
    description: 'High-end wireless noise-cancelling headphones featuring sound profile customization and up to 40 hours battery life.',
    price: 299.99,
    oldPrice: 349.99,
    rating: 4.8,
    reviewsCount: 154,
    category: 'Electronics',
    icon: 'headphones',
    badge: 'BEST SELLER',
    images: [
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop'
    ],
    stock: 8,
    finishes: ['Matte Black', 'Silver Grey', 'Navy Blue'],
    storageOptions: {},
    specs: {
      'Battery Life': 'Up to 40 Hours',
      'Driver Size': '40mm Dynamic',
      'Noise Cancellation': 'Active Hybrid ANC',
      'Bluetooth Version': 'Bluetooth 5.2',
      'Weight': '250g',
    },
    sellerId: 's2', // Apex Sound Labs
  ),
  Product(
    id: 'p2',
    name: 'Premium Leather Briefcase',
    description: 'Masterfully crafted full-grain leather briefcase designed for modern professionals. Fits laptops up to 16 inches.',
    price: 189.99,
    rating: 4.6,
    reviewsCount: 88,
    category: 'Fashion',
    icon: 'work',
    badge: 'PREMIUM',
    images: [
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=600&auto=format&fit=crop'
    ],
    stock: 5,
    finishes: ['Chestnut Brown', 'Charcoal Black'],
    storageOptions: {},
    specs: {
      'Material': 'Full-Grain Vegetable Tanned Leather',
      'Laptop Pocket': 'Fits up to 16-inch laptops',
      'Hardware': 'Solid Brass Buckles',
      'Strap': 'Adjustable Leather Shoulder Strap',
    },
    sellerId: 's3', // Urban Couture Boutique
  ),
  Product(
    id: 'p3',
    name: 'Z1 Wireless Audio Speaker',
    description: 'Portable smart home speaker with rich 360-degree acoustics, built-in voice assistants, and water-resistant materials.',
    price: 129.99,
    oldPrice: 149.99,
    rating: 4.7,
    reviewsCount: 312,
    category: 'Electronics',
    icon: 'volume_up',
    badge: 'NEW',
    images: [
      'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?q=80&w=600&auto=format&fit=crop'
    ],
    stock: 20,
    finishes: ['Slate Black', 'Chalk White'],
    storageOptions: {},
    specs: {
      'Acoustics': 'Dual Passive Radiators, 360 Sound',
      'Connectivity': 'Wi-Fi & Bluetooth 5.0',
      'Waterproof': 'IPX7 Water Resistant',
      'Dimensions': '180mm x 90mm',
    },
    sellerId: 's2', // Apex Sound Labs
  ),
  Product(
    id: 'p4',
    name: 'Aura Ceramic Mist Diffuser',
    description: 'Elegant ultrasonic humidifier and essential oil diffuser styled in textured white ceramic and solid oak base.',
    price: 49.99,
    rating: 4.9,
    reviewsCount: 42,
    category: 'Home',
    icon: 'nest_eco_leaf',
    badge: 'NEW',
    images: [
      'https://images.unsplash.com/photo-1602928321679-560bb453f190?q=80&w=600&auto=format&fit=crop'
    ],
    stock: 15,
    sizes: ['Standard', 'Family Size (+\$20)'],
    specs: {
      'Capacity': '300ml Water Tank',
      'Material': 'Hand-crafted Ceramic & Oak Wood',
      'Run Time': '8 Hours Continuous',
      'Coverage': 'Up to 300 sq ft',
      'Ambient Light': 'Warm Glow LED (Dimmable)',
    },
    sellerId: 's1', // NAND Tech Emporium
  ),
  Product(
    id: 'p5',
    name: 'Smart Leather Wallet',
    description: 'Modern leather smart wallet in navy blue with a minimalist profile. RFID protection and NAND tracker integration.',
    price: 65.00,
    oldPrice: 85.00,
    rating: 4.5,
    reviewsCount: 210,
    category: 'Accessories',
    icon: 'account_balance_wallet',
    images: [
      'https://images.unsplash.com/photo-1627124118123-e4d3db129f1c?q=80&w=600&auto=format&fit=crop'
    ],
    stock: 12,
    specs: {
      'Material': 'Premium Full-Grain Leather',
      'Capacity': 'Up to 12 Cards & Cash',
      'RFID Block': 'Yes (All Pockets)',
      'Tracking': 'Compatible with NAND Find App',
      'Profile': 'Ultra-thin (8mm)',
    },
    sellerId: 's3', // Urban Couture Boutique
  ),
];
