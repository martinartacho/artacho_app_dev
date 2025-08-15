import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:convert'; //real-time
import 'package:http/http.dart' as http; // real-time

class ApiService {

static const String baseUrl = 'https://dev.artacho.org/api';

  static Future<int> getUnreadCount(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['count'] ?? 0;
    }
    throw Exception('Error al obtener contador');
  }
}

  Future<Dio> getApiClient(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return Dio(options);
  }
}
