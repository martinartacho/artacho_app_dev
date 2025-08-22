import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Cargar notificaciones más recientes
  Future<List<Map<String, dynamic>>> getLatest(BuildContext context) async {
    try {
      final response = await ApiService.get("/notifications");

      if (response == null || response['data'] == null) {
        return [];
      }

      final data = response['data'] as List<dynamic>;

      final notifications =
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // Actualizamos contador de no leídas
      unreadCount.value =
          notifications.where((n) => n['read_at'] == null).length;

      return notifications;
    } catch (e, stack) {
      debugPrint("❌ Error cargando notificaciones: $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(int id) async {
    try {
      await ApiService.post("/$id/read", {});
      unreadCount.value = (unreadCount.value > 0) ? unreadCount.value - 1 : 0;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error marcando notificación $id como leída: $e");
    }
  }

  /// Marcar todas como leídas
  Future<void> markAllAsRead() async {
    try {
      await ApiService.post("/read-all", {});
      unreadCount.value = 0;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error marcando todas como leídas: $e");
    }
  }
}
