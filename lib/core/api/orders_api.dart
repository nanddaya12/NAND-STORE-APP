import 'package:dio/dio.dart';
import '../../features/orders/data/models/order_model.dart';

class OrdersApi {
  final Dio dio;
  OrdersApi(this.dio);

  Future<List<OrderModel>> getOrders() async {
    final response = await dio.get('/orders');
    final list = response.data as List? ?? const [];
    return list.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    final response = await dio.post('/orders', data: order.toJson());
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> updateOrderDetails(String id, OrderModel order) async {
    final response = await dio.put('/orders/$id', data: order.toJson());
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> patchOrderStatus(String id, Map<String, dynamic> status) async {
    final response = await dio.patch('/orders/$id', data: status);
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelOrder(String id) async {
    await dio.delete('/orders/$id');
  }
}
