import 'package:dio/dio.dart';
import '../../features/notifications/data/models/notification_model.dart';

class NotificationApi {
  final Dio dio;
  NotificationApi(this.dio);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/notifications');
    final list = response.data as List? ?? const [];
    return list.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> registerDeviceToken(Map<String, dynamic> token) async {
    await dio.post('/notifications/register', data: token);
  }

  Future<void> markNotificationsRead(Map<String, dynamic> body) async {
    await dio.put('/notifications/read', data: body);
  }

  Future<NotificationModel> patchNotification(String id, Map<String, dynamic> fields) async {
    final response = await dio.patch('/notifications/$id', data: fields);
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNotificationItem(String id) async {
    await dio.delete('/notifications/$id');
  }
}
