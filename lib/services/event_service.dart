import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'api_service.dart';

class EventService {
  static Future<List<EventModel>> getEvents(BuildContext context) async {
    try {
      final dio = await ApiService().getApiClient(context);
      final response = await dio.get('/events');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener eventos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error en la petición: ${e.message}');
    }
  }
}
