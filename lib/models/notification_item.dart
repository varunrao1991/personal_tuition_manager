class NotificationItem {
  final String messageId;
  final String title;
  final String body;
  final String status;
  final DateTime expiryDate;
  final DateTime createdAt;

  NotificationItem({
    required this.messageId,
    required this.title,
    required this.body,
    required this.status,
    required this.expiryDate,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      messageId: json['messageId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      status: json['status'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
