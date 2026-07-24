import 'package:dio/dio.dart';
import '../../features/catalog/data/models/product_model.dart';

class ProductApi {
  final Dio dio;
  ProductApi(this.dio);

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('/products');
    final list = response.data as List? ?? const [];
    return list.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await dio.post('/products', data: product.toJson());
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    final response = await dio.put('/products/$id', data: product.toJson());
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> patchProduct(String id, Map<String, dynamic> fields) async {
    final response = await dio.patch('/products/$id', data: fields);
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete('/products/$id');
  }
}
