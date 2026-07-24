import 'package:dio/dio.dart';
import '../../features/catalog/data/models/product_model.dart';

class SearchApi {
  final Dio dio;
  SearchApi(this.dio);

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await dio.get('/search', queryParameters: {'q': query});
    final list = response.data as List? ?? const [];
    return list.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<String>> addSearchHistory(Map<String, dynamic> body) async {
    final response = await dio.post('/search/history', data: body);
    return List<String>.from(response.data as List);
  }

  Future<List<String>> syncSearchHistory(List<String> history) async {
    final response = await dio.put('/search/history/sync', data: history);
    return List<String>.from(response.data as List);
  }

  Future<Map<String, dynamic>> patchSearchSettings(Map<String, dynamic> body) async {
    final response = await dio.patch('/search/config', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> clearSearchHistory() async {
    await dio.delete('/search/history');
  }
}
