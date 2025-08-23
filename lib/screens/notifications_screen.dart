import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => loading = true);
    try {
      final resp = await ApiService.get(context, "/notifications-api");
      setState(() {
        notifications = (resp?['data'] as List?) ?? [];
      });
    } catch (e) {
      debugPrint("❌ Error cargando notificaciones: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar notificaciones')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.post(context, "/$id/mark-read-api", {});
      await _loadNotifications();
    } catch (e) {
      debugPrint("❌ Error marcando como leída ($id): $e");
    }
  }

  /// Si no tienes endpoint para "marcar todas", hacemos bucle.
  Future<void> _markAllAsRead() async {
    try {
      for (final n in notifications) {
        if (n['read_at'] == null) {
          await ApiService.post(context, "/${n['id']}/mark-read-api", {});
        }
      }
      await _loadNotifications();
    } catch (e) {
      debugPrint("❌ Error marcando todas como leídas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Marcar todas como leídas",
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No hay notificaciones"))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isRead = n['read_at'] != null;

                      return ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text(n['title'] ?? 'Sin título'),
                        subtitle: Text(n['body'] ?? ''),
                        trailing: isRead
                            ? const Icon(Icons.done, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                onPressed: () =>
                                    _markAsRead(n['id'].toString()),
                              ),
                      );
                    },
                  ),
                ),
    );
  }
}
