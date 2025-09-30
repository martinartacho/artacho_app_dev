import 'package:flutter/material.dart';
import 'api_service.dart';

class NotificationService {
  static Future<int> getUnreadCount(BuildContext context) async {
    try {
      // debugPrint('🟡 NotificationService.getUnreadCount - Iniciando petición');
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/unread-count');
      // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟡 NotificationService - Respuesta completa: ${response.data}');
      return response.data['count'] ?? 0;
      //// debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🟢 NotificationService - Contador extraído: $count');
    } catch (e) {
      // debugPrint('🔴 NotificationService - Error al obtener el contador: $e');🔴 NotificationService - Error al obtener el contador: $e');
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
      debugPrint('✅ Notificación $notificationId marcada como leída');
      return true;
    } catch (e) {
      debugPrint('🔴 Error al marcar como leída: $e');
      return false;
    }
  }
}
