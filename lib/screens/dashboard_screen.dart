import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ignore: unused_field
  int _unreadNotifications = 0;
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _notificationsFuture = NotificationService.getNotifications(context);
    // Cargar eventos al iniciar
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).fetchEvents(context);
    });
  }

  Future<void> _fetchUnreadCount() async {
    final count = await NotificationService.getUnreadCount(context);
    setState(() {
      _unreadNotifications = count;
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
    final eventProvider = Provider.of<EventProvider>(context);
    final UserModel? user = authProvider.user;

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    }

    // Obtener próximos eventos (máximo 3)
    final upcomingEvents = eventProvider.events.isNotEmpty
        ? eventProvider.events.take(3).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo e información del usuario
            if (user != null) _buildUserGreeting(user),
            const SizedBox(height: 24),

            // Última notificación no leída
            _buildLastNotification(),
            const SizedBox(height: 24),

            // Próximos eventos
            _buildUpcomingEvents(upcomingEvents, eventProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGreeting(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${user.name}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLastNotification() {
    return FutureBuilder<List<dynamic>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const SizedBox(); // No mostrar nada si no hay notificaciones
        }

        final notifications = snapshot.data!;
        final unreadNotifications =
            notifications.where((n) => n['read_at'] == null).toList();

        if (unreadNotifications.isEmpty) {
          return const SizedBox();
        }

        final lastNotification = unreadNotifications.first;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Última notificación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  lastNotification['title'] ?? 'Sin título',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  lastNotification['body'] ?? 'Sin contenido',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEvents(List<dynamic> events, EventProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos eventos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (events.isEmpty)
          const Text('No hay eventos próximos')
        else
          Column(
            children: events.map((event) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: event['has_questions']
                      ? const Icon(Icons.question_answer, color: Colors.blue)
                      : const Icon(Icons.event, color: Colors.grey),
                  title: Text(event['title'] ?? 'Sin título'),
                  subtitle: Text(_formatDate(event['start'])),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegar a pantalla de detalle del evento
                    Navigator.pushNamed(
                      context,
                      '/event-detail',
                      arguments: event,
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "Fecha no especificada";

    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha inválida";
    }
  }
}
