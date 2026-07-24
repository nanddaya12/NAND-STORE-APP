class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'Order', 'Offer', 'System'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
