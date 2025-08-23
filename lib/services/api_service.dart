import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  Future<Dio> getApiClient(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final options = BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return Dio(options);
  }

  /// Métodos de conveniencia para no repetir `getApiClient`
  static Future<dynamic> get(BuildContext context, String path) async {
    final api = await ApiService().getApiClient(context);
    final response = await api.get(path);
    return response.data;
  }

  static Future<dynamic> post(
      BuildContext context, String path, Map<String, dynamic> data) async {
    final api = await ApiService().getApiClient(context);
    final response = await api.post(path, data: data);
    return response.data;
  }
}
