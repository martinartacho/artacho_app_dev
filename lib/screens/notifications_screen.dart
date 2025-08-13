import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final data = await NotificationService.getNotifications(context);
    setState(() {
      _notifications = data;
    });
  }

  Future<void> markAsReadAndRefresh(int id) async {
    final success =
        await NotificationService.markNotificationAsRead(context, id);
    if (success) {
      await fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final noti = _notifications[index];
          final isRead = noti['read_at'] != null;
          return ListTile(
            title: Text(noti['title']),
            subtitle: Text(noti['body']),
            trailing: isRead ? null : const Icon(Icons.markunread),
            onTap: () => markAsReadAndRefresh(noti['id']),
          );
        },
      ),
    );
  }
}
