import 'package:dio/dio.dart';

class ProfileApi {
  final Dio dio;
  ProfileApi(this.dio);

  Future<Map<String, dynamic>> getProfileDetails() async {
    final response = await dio.get('/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadAvatar(Map<String, dynamic> body) async {
    final response = await dio.post('/profile/avatar', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfileInfo(Map<String, dynamic> body) async {
    final response = await dio.put('/profile', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchProfileAddress(Map<String, dynamic> body) async {
    final response = await dio.patch('/profile/address', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deactivateProfile() async {
    await dio.delete('/profile/deactivate');
  }
}
