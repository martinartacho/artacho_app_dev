import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  List<dynamic> _events = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/events');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          _events = data['data'];
        } else {
          _error = 'Error al obtener eventos';
        }
      } else {
        _error = 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchEventDetails(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception('Error al obtener detalles del evento');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  Future<void> submitAnswer({
    required int eventId,
    required int questionId,
    required String answer,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/events/$eventId/answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'question_id': questionId,
          'answer': answer,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al enviar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAnswer({
    required int answerId,
    required String answer,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/answers/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'answer': answer,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al actualizar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnswer(int answerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/answers/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEventResponses(
      BuildContext context, int eventId) async {
    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/events/$eventId/user-responses');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al cargar respuestas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
