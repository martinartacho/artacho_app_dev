import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<Map<String, dynamic>> _notifications = [];

  ValueNotifier<int> get unreadCount => _service.unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> init({required String baseUrl, required String token}) async {
    await _service.init(baseUrl: baseUrl, bearerToken: token);
  }

  Future<List<Map<String, dynamic>>> getLatest(BuildContext context) async {
    _notifications = await _service.fetchLatest(context);
    notifyListeners();
    return _notifications;
  }

  Future<void> markAsRead(int id) async {
    await _service.markAsRead(id);

    // Update the local notification list
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read_at'] = DateTime.now().toIso8601String();
      notifyListeners();
    }
  }
}
