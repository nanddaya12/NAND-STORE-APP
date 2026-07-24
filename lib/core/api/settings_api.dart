import 'package:dio/dio.dart';

class SettingsApi {
  final Dio dio;
  SettingsApi(this.dio);

  Future<Map<String, dynamic>> getAppConfiguration() async {
    final response = await dio.get('/settings');
    return response.data as Map<String, dynamic>;
  }

  Future<void> submitAppFeedback(Map<String, dynamic> feedback) async {
    await dio.post('/settings/feedback', data: feedback);
  }

  Future<Map<String, dynamic>> updateSettingsConfig(Map<String, dynamic> settings) async {
    final response = await dio.put('/settings', data: settings);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchThemeMode(Map<String, dynamic> body) async {
    final response = await dio.patch('/settings/theme', data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteLocalCache() async {
    await dio.delete('/settings/cache');
  }
}
