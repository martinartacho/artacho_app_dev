class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      read: json['read'] ?? false,
    );
  }
}
