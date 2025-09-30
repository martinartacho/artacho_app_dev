import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/events_calendar_screen.dart';
import '../services/notification_service.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  int _unreadNotificationsCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EventsCalendarScreen(),
    const NotificationsScreen(),
    Container(),
  ];

  @override
  void initState() {
    super.initState();
    // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 MainScaffold initState - Iniciando _fetchUnreadCount');
    _fetchUnreadCount();
  }

  // Método para obtener el contador de notificaciones no leídas
  Future<void> _fetchUnreadCount() async {
    // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 _fetchUnreadCount llamado');
    try {
      final count = await NotificationService.getUnreadCount(context);
      // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟢 Contador recibido: $count');
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
          // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟢 _unreadNotificationsCount actualizado a: $count');
        });
      } else {
        // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🔴 Widget no está montado, no se puede actualizar');
      }
    } catch (e) {
      // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🔴 Error en _fetchUnreadCount: $e');
    }
  }

  void _onItemTapped(int index) {
    // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 _onItemTapped: índice $index');
    if (index == 3) {
      // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 Abriendo drawer');
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });

      // Actualizar contador cuando se selecciona notificaciones
      if (index == 2) {
        // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 Notificaciones seleccionado, actualizando contador');
        _fetchUnreadCount();
      }
    }
  }

  // Widget para el ícono de notificaciones con badge
  Widget _buildNotificationIcon() {
    // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 _buildNotificationIcon - Contador: $_unreadNotificationsCount');
    return Stack(
      children: [
        const Icon(Icons.notifications),
        if (_unreadNotificationsCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
              ),
              child: Text(
                _unreadNotificationsCount > 9
                    ? '9+'
                    : _unreadNotificationsCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 MainScaffold build - Contador: $_unreadNotificationsCount');
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: _screens[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú de Usuario',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Enviar sugerencia'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feedback');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(),
            label: 'Notificaciones',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menú',
          ),
        ],
      ),
    );
  }
}
