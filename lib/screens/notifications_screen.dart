import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    _future = provider.getLatest(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar notificaciones"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay notificaciones"));
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif['read_at'] != null;

              return ListTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(notif['title'] ?? 'Sin título'),
                subtitle: Text(notif['body'] ?? 'Sin contenido'),
                trailing: Icon(
                  Icons.circle,
                  color: isRead ? Colors.green : Colors.red,
                  size: 12,
                ),
                onTap: () async {
                  if (!isRead) {
                    await provider.markAsRead(notif['id']);
                    setState(() {
                      notif['read_at'] = DateTime.now().toIso8601String();
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
