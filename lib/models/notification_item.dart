class NotificationItem {
  final int id;
  final String title;
  final String body;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// Create a new instance with updated values using copyWith.
  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
    );
  }
}
