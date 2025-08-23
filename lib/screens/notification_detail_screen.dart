import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Notificación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          data.toString(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
