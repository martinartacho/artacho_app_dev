import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences prefs;
  String? _token;
  bool _isAuthenticated = false;
  UserModel? _user;

  AuthProvider({required this.prefs}) {
    _token = prefs.getString('token');
    _isAuthenticated = _token != null;

    // Cargar usuario si existe
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        developer.log('Error al cargar usuario: $e', name: 'AuthProvider');
      }
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  UserModel? get user => _user;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);
      developer.log('Login response: $responseBody', name: 'AuthProvider');

      if (response.statusCode == 200) {
        if (responseBody['token'] != null) {
          _token = responseBody['token'];
          _isAuthenticated = true;

          if (responseBody['user'] != null) {
            _user = UserModel.fromJson(responseBody['user']);
            await prefs.setString('user', jsonEncode(_user!.toJson()));
          }

          await prefs.setString('token', _token!);
          notifyListeners();
          return true; // ✅ Login exitoso
        } else {
          throw Exception('Token no encontrado en la respuesta');
        }
      } else {
        final errorMsg = responseBody['message'] ?? 'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log('Error en login: $e', name: 'AuthProvider', error: e);
      return false; // ❌ Login fallido
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/register'),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);
      developer.log('Register response: $responseBody', name: 'AuthProvider');

      if (response.statusCode == 201) {
        if (responseBody['access_token'] != null ||
            responseBody['token'] != null) {
          _token = responseBody['access_token'] ?? responseBody['token'];
          _isAuthenticated = true;

          if (responseBody['user'] != null) {
            _user = UserModel.fromJson(responseBody['user']);
            await prefs.setString('user', jsonEncode(_user!.toJson()));
          }

          await prefs.setString('token', _token!);
          print('🔑 TOKEN desde Flutter: $_token');
          notifyListeners();
        } else {
          print('🔑 NO TOKEN desde Flutter');
          throw Exception('Token no encontrado en la respuesta');
        }
      } else {
        final errorMsg = responseBody['message'] ??
            responseBody['errors']?.toString() ??
            'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log('Error en registro: $e', name: 'AuthProvider', error: e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Limpieza local primero
      _token = null;
      _isAuthenticated = false;
      _user = null;
      await prefs.remove('token');
      await prefs.remove('user');

      notifyListeners(); // Importante: notificar a los listeners primero

      // Luego intentar logout remoto
      if (_token != null) {
        await http.post(
          Uri.parse('${Config.baseUrl}/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      developer.log('Error en logout: $e', name: 'AuthProvider');
    } finally {
      // Limpiar estado local independientemente del resultado del logout remoto
      _token = null;
      _isAuthenticated = false;
      _user = null;
      await prefs.remove('token');
      await prefs.remove('user');
      notifyListeners();
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/forgot-password'),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);
      developer.log(
        'Recover password response: $responseBody',
        name: 'AuthProvider',
      );

      if (response.statusCode != 200) {
        final errorMsg = responseBody['message'] ?? 'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log(
        'Error en recoverPassword: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> loadUserProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseBody = jsonDecode(response.body);
      developer.log(
        'User profile response: $responseBody',
        name: 'AuthProvider',
      );

      if (response.statusCode == 200) {
        if (responseBody['id'] != null) {
          _user = UserModel.fromJson(responseBody);
          await prefs.setString('user', jsonEncode(_user!.toJson()));
          notifyListeners();
        } else {
          throw Exception('Datos de usuario no encontrados');
        }
      } else {
        final errorMsg = responseBody['message'] ?? 'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log(
        'Error cargando perfil: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String email) async {
    try {
      if (_token == null) throw Exception('No autenticado');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      final responseBody = jsonDecode(response.body);
      developer.log(
        'Update profile response: $responseBody',
        name: 'AuthProvider',
      );

      if (response.statusCode == 200) {
        // Actualizar la información del usuario localmente
        if (responseBody['user'] != null) {
          _user = UserModel.fromJson(responseBody['user']);
          await prefs.setString('user', jsonEncode(_user!.toJson()));
          notifyListeners();
        }
      } else {
        final errorMsg = responseBody['message'] ?? 'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log(
        'Error actualizando perfil: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      if (_token == null) throw Exception('No autenticado');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final responseBody = jsonDecode(response.body);
      developer.log(
        'Change password response: $responseBody',
        name: 'AuthProvider',
      );

      if (response.statusCode == 200) {
        // No necesitamos actualizar datos de usuario aquí
      } else {
        final errorMsg = responseBody['message'] ??
            responseBody['errors']?.toString() ??
            'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log(
        'Error cambiando contraseña: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_token == null) throw Exception('No autenticado');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await logout(); // Cerrar sesión después de eliminar la cuenta
      } else {
        final errorMsg = responseBody['message'] ?? 'Error desconocido';
        throw Exception('$errorMsg (${response.statusCode})');
      }
    } catch (e) {
      developer.log(
        'Error eliminando cuenta: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }
}
