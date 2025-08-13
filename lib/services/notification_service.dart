import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  static Future<int> getUnreadCount(BuildContext context) async {
    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/unread-count');
      return response.data['count'] ?? 0;
    } catch (e) {
      debugPrint('🔴 Error al obtener el contador: $e');
      return 0;
    }
  }

  static Future<List<dynamic>> getNotifications(BuildContext context) async {
    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/notifications-api');
      debugPrint('🔔 Respuesta completa: ${response.data}');
      return response.data['notifications'] ?? [];
    } catch (e) {
      debugPrint('🔴 Error al obtener notificaciones: $e');
      return [];
    }
  }

// Marcar notificación como leída
  static Future<bool> markNotificationAsRead(
      BuildContext context, int notificationId) async {
    try {
      final dio = await ApiService().getApiClient(context);
      await dio.post('/$notificationId/mark-read-api');
      print('✅ Notificación $notificationId marcada como leída');
      return true;
    } catch (e) {
      print('🔴 Error al marcar como leída: $e');
      return false;
    }
  }
/* Repetido ??
  static Future<bool> markNotificationAsRead(
      BuildContext context, int notificationId) async {
    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.post('/$notificationId/mark-read-api');
      debugPrint('✅ Notificación $notificationId marcada como leída');
      return true;
    } catch (e) {
      debugPrint('🔴 Error al marcar como leída: $e');
      return false;
    }
  }*/
}
