import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos al abrir la pantalla
    Future.microtask(
        () => Provider.of<EventProvider>(context, listen: false).fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.events.length,
              itemBuilder: (context, index) {
                final event = provider.events[index];
                return ListTile(
                  title: Text(event['title'] ?? "Sin título"),
                  subtitle: Text(event['start'] ?? ""),
                );
              },
            ),
    );
  }
}
