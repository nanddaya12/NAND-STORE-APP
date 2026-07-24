import 'package:dio/dio.dart';

class WishlistApi {
  final Dio dio;
  WishlistApi(this.dio);

  Future<List<String>> getWishlistIds() async {
    final response = await dio.get('/wishlist');
    final list = response.data as List? ?? const [];
    return List<String>.from(list);
  }

  Future<List<String>> addToWishlist(Map<String, dynamic> body) async {
    final response = await dio.post('/wishlist', data: body);
    return List<String>.from(response.data as List);
  }

  Future<List<String>> syncWishlist(List<String> ids) async {
    final response = await dio.put('/wishlist/sync', data: ids);
    return List<String>.from(response.data as List);
  }

  Future<List<String>> patchWishlistItem(String id, Map<String, dynamic> data) async {
    final response = await dio.patch('/wishlist/$id', data: data);
    return List<String>.from(response.data as List);
  }

  Future<List<String>> removeFromWishlist(String id) async {
    final response = await dio.delete('/wishlist/$id');
    return List<String>.from(response.data as List);
  }
}
