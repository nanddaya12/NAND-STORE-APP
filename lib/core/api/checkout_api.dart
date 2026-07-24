import 'package:dio/dio.dart';

class CheckoutApi {
  final Dio dio;
  CheckoutApi(this.dio);

  Future<Map<String, dynamic>> getCheckoutOptions() async {
    final response = await dio.get('/checkout/options');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitCheckout(Map<String, dynamic> data) async {
    final response = await dio.post('/checkout/submit', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCheckoutAddress(Map<String, dynamic> address) async {
    final response = await dio.put('/checkout/address', data: address);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchCheckoutMethod(Map<String, dynamic> method) async {
    final response = await dio.patch('/checkout/method', data: method);
    return response.data as Map<String, dynamic>;
  }

  Future<void> cancelCheckoutSession() async {
    await dio.delete('/checkout/session');
  }
}
