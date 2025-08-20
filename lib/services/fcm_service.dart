import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/auth_provider.dart';

// Actualiza la clase FCMService con manejo de notificaciones en tiempo real
class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializar FCM + Notificaciones Locales
  static Future<void> initFCM(BuildContext context) async {
    try {
      // 1. Configurar notificaciones locales
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _notificationsPlugin.initialize(initializationSettings);

      // 2. Solicitar permisos
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Obtener token y guardar en backend
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📲 Token FCM: $token');
        await _saveTokenToBackend(context, token);
      }

      // 4. Configurar manejadores
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Notificación en primer plano');
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotification(context, message.data);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e) {
      print('❌ Error initFCM: $e');
    }
  }

  // Mostrar notificación local
  static void _showNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'artacho_channel',
      'Artacho Notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(android: androidPlatformChannelSpecifics),
      payload: jsonEncode(message.data),
    );
  }

  // Manejador para background/terminado
  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print('📨 Notificación en segundo plano: ${message.messageId}');
    _showNotification(message);
  }

  // Navegar al hacer clic
  static void _handleNotification(
      BuildContext context, Map<String, dynamic> data) {
    Navigator.of(context).pushNamed('/notification-detail', arguments: data);
  }

// }

  static Future<void> _saveTokenToBackend(
      BuildContext context, String token) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userToken = authProvider.token;

      if (userToken == null) {
        print('⚠️ No hay token de sesión del usuario');
        return;
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/save-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_name': Platform.localHostname,
        }),
      );

      print('📡 Respuesta backend: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('❌ Error enviando token al backend: $e');
    }
  }
}
