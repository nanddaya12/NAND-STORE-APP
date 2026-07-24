import 'package:dio/dio.dart';
import '../../features/cart/data/models/cart_item_model.dart';

class CartApi {
  final Dio dio;
  CartApi(this.dio);

  Future<List<CartItemModel>> getCartItems() async {
    final response = await dio.get('/cart');
    final list = response.data as List? ?? const [];
    return list.map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<CartItemModel> addToCart(CartItemModel item) async {
    final response = await dio.post('/cart', data: item.toJson());
    return CartItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CartItemModel> updateCartQty(String id, Map<String, dynamic> body) async {
    final response = await dio.put('/cart/$id', data: body);
    return CartItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CartItemModel> patchCartItem(String id, Map<String, dynamic> fields) async {
    final response = await dio.patch('/cart/$id', data: fields);
    return CartItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCartItem(String id) async {
    await dio.delete('/cart/$id');
  }
}
