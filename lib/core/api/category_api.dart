import 'package:dio/dio.dart';

class CategoryApi {
  final Dio dio;
  CategoryApi(this.dio);

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await dio.get('/categories');
    final list = response.data as List? ?? const [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> category) async {
    final response = await dio.post('/categories', data: category);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> category) async {
    final response = await dio.put('/categories/$id', data: category);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchCategory(String id, Map<String, dynamic> fields) async {
    final response = await dio.patch('/categories/$id', data: fields);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id) async {
    await dio.delete('/categories/$id');
  }
}
