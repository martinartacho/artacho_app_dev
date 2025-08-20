import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/auth_provider.dart';

class NotificationService {
  late String _baseUrl;
  late String _token;

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> init(
      {required String baseUrl, required String bearerToken}) async {
    _baseUrl = baseUrl;
    _token = bearerToken;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Map<String, dynamic>>> fetchLatest(BuildContext context) async {
    final url = Uri.parse('$_baseUrl/notifications-api');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final notifications = data.cast<Map<String, dynamic>>();

      // Actualizar contador de no leídos
      final unread = notifications.where((n) => n['read_at'] == null).length;
      unreadCount.value = unread;

      return notifications;
    } else {
      debugPrint('Error fetchLatest: ${response.statusCode} ${response.body}');
      return [];
    }
  }

  Future<void> markAsRead(int id) async {
    final url = Uri.parse('$_baseUrl/$id/mark-read-api');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      if (unreadCount.value > 0) {
        unreadCount.value = unreadCount.value - 1;
      }
    } else {
      debugPrint('Error markAsRead: ${response.statusCode} ${response.body}');
    }
  }
}
