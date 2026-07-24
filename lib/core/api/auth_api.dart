import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;
  AuthApi(this.dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/auth/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final response = await dio.post('/auth/login', data: credentials);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCredentials(Map<String, dynamic> credentials) async {
    final response = await dio.put('/auth/update', data: credentials);
    return response.data as Map<String, dynamic>;
  }

  Future<void> patchPassword(Map<String, dynamic> data) async {
    await dio.patch('/auth/password', data: data);
  }

  Future<void> deleteAccount() async {
    await dio.delete('/auth/account');
  }
}
