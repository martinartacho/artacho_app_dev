class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      read: json['pivot']?['read'] ?? false,
    );
  }
}
