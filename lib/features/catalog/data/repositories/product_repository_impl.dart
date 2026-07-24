import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../catalog/data/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient = ApiClient();
  final HiveService _hiveService = HiveService.instance;

  @override
  Future<List<Product>> getProducts() async {
    final hasInternet = await _apiClient.isConnected();

    if (hasInternet) {
      try {
        // Simulated network call or actual API call:
        // final List<ProductModel> remoteList = await ProductApi(_apiClient.dio).getProducts();
        // Since we are mocking backend, load list:
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Update local box cache
        final productsBox = _hiveService.getBox('products');
        await productsBox.clear();
        for (var p in dummyProductsModelList) {
          await productsBox.put(p.id, p.toJson());
        }
        return dummyProductsModelList;
      } catch (e) {
        // Fallback to cache on remote failure
        return _getLocalProducts();
      }
    } else {
      // Offline first loading
      return _getLocalProducts();
    }
  }

  @override
  Future<Product> getProductDetail(String id) async {
    final hasInternet = await _apiClient.isConnected();
    if (hasInternet) {
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        return dummyProductsModelList.firstWhere((p) => p.id == id);
      } catch (e) {
        return _getLocalProduct(id);
      }
    } else {
      return _getLocalProduct(id);
    }
  }

  List<Product> _getLocalProducts() {
    final cached = _hiveService.getBox('products').values.toList();
    if (cached.isEmpty) return dummyProductsModelList; // Seed default list on empty
    return cached.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Product _getLocalProduct(String id) {
    final cached = _hiveService.getBox('products').get(id);
    if (cached == null) return dummyProductsModelList.firstWhere((p) => p.id == id);
    return ProductModel.fromJson(Map<String, dynamic>.from(cached));
  }
}

// Seed mock products in data model form
final List<ProductModel> dummyProductsModelList = [
  const ProductModel(
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
    stock: 8,
    finishes: ['Matte Black', 'Silver Grey', 'Navy Blue'],
    specs: {
      'Battery Life': 'Up to 40 Hours',
      'Driver Size': '40mm Dynamic',
      'Noise Cancellation': 'Active Hybrid ANC',
    },
  ),
  const ProductModel(
    id: 'p2',
    name: 'Premium Leather Briefcase',
    description: 'Masterfully crafted full-grain leather briefcase designed for modern professionals. Fits laptops up to 16 inches.',
    price: 189.99,
    rating: 4.6,
    reviewsCount: 88,
    category: 'Fashion',
    icon: 'work',
    badge: 'PREMIUM',
    stock: 5,
    finishes: ['Chestnut Brown', 'Charcoal Black'],
    specs: {
      'Material': 'Full-Grain Vegetable Tanned Leather',
      'Laptop Pocket': 'Fits up to 16-inch laptops',
    },
  ),
];
