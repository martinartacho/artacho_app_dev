import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/auth_provider.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initFCM(BuildContext context) async {
    try {
      if (kIsWeb) {
        await _firebaseMessaging.requestPermission();
      }

      final token = await _firebaseMessaging.getToken();

      if (token != null) {
        print('📲 Token FCM obtenido: $token');
        await _saveTokenToBackend(context, token);
      } else {
        print('⚠️ No se pudo obtener el token FCM');
      }
    } catch (e) {
      print('❌ Error en initFCM: $e');
    }
  }

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
