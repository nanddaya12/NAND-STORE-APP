import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationItem {
  NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.timestamp,
    required super.type,
    super.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromEntity(NotificationItem entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      timestamp: entity.timestamp,
      type: entity.type,
      isRead: entity.isRead,
    );
  }
}
