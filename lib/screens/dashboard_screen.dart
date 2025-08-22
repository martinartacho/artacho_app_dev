import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/user_model.dart';
import '../widgets/dashboard_user_info.dart';
import '../widgets/dashboard_menu_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Future<List<dynamic>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();

    // 🔑 Muy importante: no uses context en initState directamente.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      setState(() {
        _notificationsFuture = notificationProvider.getLatest(context);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    if (authProvider.user != null && authProvider.user?.createdAt == null) {
      authProvider.loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final UserModel? user = authProvider.user;

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(user),
          _buildNotificationsList(notificationProvider),
          const DashboardMenuSection(),
        ],
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(notificationProvider.unreadCount.value),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(int unreadCount) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notificaciones',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menú',
        ),
      ],
    );
  }

  Widget _buildDashboard(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (user != null) ...[
            DashboardUserInfo(user: user),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationProvider provider) {
    if (_notificationsFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<dynamic>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar notificaciones'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay notificaciones'));
        }

        final notifications = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const Divider(),
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
    );
  }
}
