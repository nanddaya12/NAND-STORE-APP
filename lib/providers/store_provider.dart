import 'package:flutter/material.dart';
import '../models/store_models.dart';

class StoreProvider with ChangeNotifier {
  final List<Product> _productsList = List.from(dummyProducts);
  final List<SellerProfile> _sellers = [
    const SellerProfile(
      id: 's1',
      name: 'Nand Kishore',
      shopName: 'NAND Tech Emporium',
      email: 'nand@tech.com',
      phone: '+91 99887 76655',
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
      bannerImage: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?q=80&w=600&auto=format&fit=crop',
      description: 'Your premier shop for premium ceramic mist diffusers, ambient lighting, and bespoke minimalist lifestyle tech products.',
      rating: 4.9,
      reviews: [
        SellerReview(
          reviewerName: 'John Doe',
          rating: 5.0,
          comment: 'Perfect mist diffuser! Elegant textured ceramic shell and the warm glow light looks amazing at night.',
          date: 'July 18, 2026',
        ),
        SellerReview(
          reviewerName: 'Alice Miller',
          rating: 4.8,
          comment: 'Very premium packaging. Essential oils spread evenly throughout my large workspace. Fast shipping!',
          date: 'July 15, 2026',
        ),
      ],
    ),
    const SellerProfile(
      id: 's2',
      name: 'Alex Rivera',
      shopName: 'Apex Sound Labs',
      email: 'alex@apexsound.com',
      phone: '+1 415 555 2671',
      profileImage: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop',
      bannerImage: 'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?q=80&w=600&auto=format&fit=crop',
      description: 'Acoustic engineering and high-fidelity smart audio gear. Specializing in active noise cancelling headphones and Smart Z1 360 Speakers.',
      rating: 4.8,
      reviews: [
        SellerReview(
          reviewerName: 'Robert Dow',
          rating: 5.0,
          comment: 'Hi-Fi acoustics on the Z1 wireless speaker are unreal! Deep bass responses and crystal clear vocals.',
          date: 'July 12, 2026',
        ),
        SellerReview(
          reviewerName: 'Elena Rostova',
          rating: 4.6,
          comment: 'X-1 headphones ANC blocks office background noise completely. Batterylife has lasted me over a week.',
          date: 'July 05, 2026',
        ),
      ],
    ),
    const SellerProfile(
      id: 's3',
      name: 'Sophia Loren',
      shopName: 'Urban Couture Boutique',
      email: 'sophia@urbancouture.com',
      phone: '+1 212 555 8901',
      profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      bannerImage: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=600&auto=format&fit=crop',
      description: 'Bespoke hand-crafted leather wallets, briefcase layouts, and elite design fashion accessories matching modern urban lifestyles.',
      rating: 4.7,
      reviews: [
        SellerReview(
          reviewerName: 'Marcus Aurelius',
          rating: 4.9,
          comment: 'Briefcase is built like a tank. Solid vegetable-tanned leather and flawless stitching details.',
          date: 'July 14, 2026',
        ),
        SellerReview(
          reviewerName: 'Sophia Lee',
          rating: 4.5,
          comment: 'Beautiful navy blue smart wallet. Minimalist profile, fits 10 cards easily without bloating pocket.',
          date: 'July 10, 2026',
        ),
      ],
    ),
  ];
  final Map<String, double> _coupons = {
    'NAND20': 0.20,
    'WELCOME10': 0.10,
  };

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Popularity';
  final List<CartItem> _cart = [];
  final List<String> _wishlist = [];
  String _appliedCoupon = '';
  double _discountPercentage = 0.0;
  int _loyaltyPoints = 250;
  
  // Custom delivery method cost
  double _selectedDeliveryCost = -1.0; // -1 means use default estimatedShipping logic
  
  // Dynamic list tracking Recently Viewed history
  final List<Product> _recentlyViewed = [];

  // Search history list
  final List<String> _searchHistory = ['pro max', 'audio', 'mist'];

  // Orders list with pre-seeded mock entries
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-98765',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'items': [
        {
          'name': 'Aura Mist Diffuser (White)',
          'price': 49.99,
          'quantity': 1,
        }
      ],
      'total': 53.99,
      'status': 'Processing',
      'shippingAddress': 'Nand Kishore, 123 Tech Park Lane, Bangalore, 560001 (Tel: +91 99887 76655)',
      'billingAddress': 'Same as shipping',
      'deliveryMethod': 'Standard Delivery (\$0.00)',
      'paymentMethod': 'Credit Card',
      'orderNotes': 'Please leave at reception',
    },
    {
      'id': 'ORD-12345',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'items': [
        {
          'name': 'X-1 Pro Headphones (Matte Black)',
          'price': 299.99,
          'quantity': 1,
        }
      ],
      'total': 329.99,
      'status': 'Delivered',
      'shippingAddress': 'Nand Kishore, 123 Tech Park Lane, Bangalore, 560001 (Tel: +91 99887 76655)',
      'billingAddress': 'Same as shipping',
      'deliveryMethod': 'Standard Delivery (\$0.00)',
      'paymentMethod': 'Credit Card',
      'orderNotes': '',
    }
  ];

  // Notifications list seeded with mock items
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      title: 'Order ORD-98765 Shipped!',
      body: 'Your package containing Aura Mist Diffuser is on the way to Bangalore.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'Order',
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Exclusive Offer inside!',
      body: 'Get 20% discount on next checkout using code NAND20.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Offer',
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'System Security Update',
      body: 'Your biometric logins configurations have been updated securely.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: 'System',
      isRead: true,
    ),
  ];

  // Getters
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  List<CartItem> get cart => _cart;
  List<String> get wishlist => _wishlist;
  String get appliedCoupon => _appliedCoupon;
  double get discountPercentage => _discountPercentage;
  int get loyaltyPoints => _loyaltyPoints;
  List<Map<String, dynamic>> get orders => _orders;
  List<Product> get recentlyViewed => _recentlyViewed;
  double get selectedDeliveryCost => _selectedDeliveryCost;
  List<String> get searchHistory => _searchHistory;
  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  List<Product> get allProducts => _productsList;
  Map<String, double> get coupons => _coupons;
  List<SellerProfile> get allSellers => _sellers;

  List<SellerProfile> get sellers {
    if (_searchQuery.trim().isEmpty) return _sellers;
    return _sellers.where((s) {
      return s.shopName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Filtered and Sorted Products
  List<Product> get products {
    List<Product> list = _productsList.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Sort
    if (_sortBy == 'Price Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  // Setters & Actions
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setDeliveryCost(double cost) {
    _selectedDeliveryCost = cost;
    notifyListeners();
  }

  // Cart operations
  void addToCart(Product product, {String finish = '', String storage = '', String size = '', double addedCost = 0.0}) {
    final existingIndex = _cart.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedFinish == finish &&
        item.selectedStorage == storage &&
        item.selectedSize == size);

    if (existingIndex >= 0) {
      _cart[existingIndex].quantity += 1;
    } else {
      _cart.add(CartItem(
        product: product,
        selectedFinish: finish,
        selectedStorage: storage,
        selectedSize: size,
        addedCost: addedCost,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId, {String finish = '', String storage = '', String size = ''}) {
    _cart.removeWhere((item) =>
        item.product.id == productId &&
        item.selectedFinish == finish &&
        item.selectedStorage == storage &&
        item.selectedSize == size);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQty, {String finish = '', String storage = '', String size = ''}) {
    final index = _cart.indexWhere((item) =>
        item.product.id == productId &&
        item.selectedFinish == finish &&
        item.selectedStorage == storage &&
        item.selectedSize == size);

    if (index >= 0) {
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  // Wishlist operations
  void toggleWishlist(String productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();
  }

  bool isInWishlist(String productId) => _wishlist.contains(productId);

  // History operations
  void addToRecentlyViewed(Product product) {
    _recentlyViewed.removeWhere((p) => p.id == product.id);
    _recentlyViewed.insert(0, product);
    if (_recentlyViewed.length > 5) {
      _recentlyViewed.removeLast();
    }
    notifyListeners();
  }

  // Search History operations
  void addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    _searchHistory.removeWhere((q) => q.toLowerCase() == query.trim().toLowerCase());
    _searchHistory.insert(0, query.trim());
    if (_searchHistory.length > 8) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  // Update order status method
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o['id'] == orderId);
    if (index >= 0) {
      _orders[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  // Notifications operations
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Cart financial calculations
  double get cartSubtotal {
    return _cart.fold(0.0, (sum, item) => sum + item.totalItemPrice);
  }

  double get discountAmount {
    return cartSubtotal * _discountPercentage;
  }

  double get cartTax {
    return (cartSubtotal - discountAmount) * 0.08; // 8% sales tax
  }

  double get estimatedShipping {
    final sub = cartSubtotal;
    if (sub == 0) return 0.0;
    if (_selectedDeliveryCost >= 0.0) return _selectedDeliveryCost;
    return sub >= 100.0 ? 0.0 : 9.99; // Free shipping over $100, else $9.99
  }

  double get cartTotal {
    final sub = cartSubtotal;
    if (sub == 0) return 0.0;
    return sub - discountAmount + cartTax + estimatedShipping;
  }

  // Coupon application
  bool applyCoupon(String code) {
    final upperCode = code.toUpperCase();
    if (_coupons.containsKey(upperCode)) {
      _appliedCoupon = upperCode;
      _discountPercentage = _coupons[upperCode]!;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = '';
    _discountPercentage = 0.0;
    notifyListeners();
  }

  // Dynamic Product Management
  void addProduct(Product product) {
    _productsList.insert(0, product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _productsList.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _productsList[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _productsList.removeWhere((p) => p.id == id);
    // Also remove from cart
    _cart.removeWhere((item) => item.product.id == id);
    // Also remove from wishlist
    _wishlist.remove(id);
    notifyListeners();
  }

  SellerProfile getSellerProfile(String id) {
    return _sellers.firstWhere(
      (s) => s.id == id,
      orElse: () => _sellers[0],
    );
  }

  void registerSellerProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) {
    if (!_sellers.any((s) => s.id == id)) {
      _sellers.add(SellerProfile(
        id: id,
        name: name,
        shopName: '$name\'s Shop',
        email: email,
        phone: phone,
        profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
        bannerImage: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?q=80&w=600&auto=format&fit=crop',
        description: 'Welcome to our newly registered NAND boutique store!',
        rating: 5.0,
      ));
      notifyListeners();
    }
  }

  // Dynamic Coupon Management
  void addCoupon(String code, double discount) {
    _coupons[code.toUpperCase()] = discount;
    notifyListeners();
  }

  void removeCouponFromList(String code) {
    final upperCode = code.toUpperCase();
    _coupons.remove(upperCode);
    if (_appliedCoupon == upperCode) {
      removeCoupon();
    }
    notifyListeners();
  }

  // Extended Checkout simulation
  String checkout({
    required String name,
    required String email,
    required String address,
    required String phone,
    required String city,
    required String zip,
    required String billingAddress,
    required String deliveryMethod,
    required String paymentMethod,
    required String orderNotes,
  }) {
    if (_cart.isEmpty) return '';

    final double total = cartTotal;
    final int pointsEarned = (total / 10).floor();
    _loyaltyPoints += pointsEarned;

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    _orders.insert(0, {
      'id': orderId,
      'date': DateTime.now(),
      'items': _cart.map((item) {
        String detailText = '';
        if (item.selectedFinish.isNotEmpty) detailText += ' (${item.selectedFinish}';
        if (item.selectedStorage.isNotEmpty) {
          detailText += detailText.isEmpty ? ' (${item.selectedStorage})' : ', ${item.selectedStorage})';
        } else if (item.selectedSize.isNotEmpty) {
          detailText += detailText.isEmpty ? ' (${item.selectedSize})' : ', ${item.selectedSize})';
        } else if (detailText.isNotEmpty) {
          detailText += ')';
        }
        return {
          'name': '${item.product.name}$detailText',
          'price': item.singleItemPrice,
          'quantity': item.quantity,
        };
      }).toList(),
      'total': total,
      'status': 'Processing',
      'shippingAddress': '$name, $address, $city, $zip (Tel: $phone)',
      'billingAddress': billingAddress,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'orderNotes': orderNotes,
    });

    // Automatically send an order notification!
    _notifications.insert(0, NotificationItem(
      id: 'n-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order $orderId Confirmed!',
      body: 'Your order has been placed successfully and is now Processing.',
      timestamp: DateTime.now(),
      type: 'Order',
      isRead: false,
    ));

    _cart.clear();
    _appliedCoupon = '';
    _discountPercentage = 0.0;
    _selectedDeliveryCost = -1.0; // Reset delivery cost
    notifyListeners();
    return orderId;
  }
}
