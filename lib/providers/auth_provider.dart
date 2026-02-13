import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/push_notification_service.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  final ApiService _apiService = ApiService();

  AuthProvider() {
    _apiService.onUnauthorized = () {
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    };
  }

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post('/login', data: {
        'email': email,
        'password': password,
        'device_name': 'flutter_app',
      });

      if (response.statusCode == 200) {
        String token = response.data['token'];
        _user = User.fromJson(response.data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));

        _isAuthenticated = true;

        // Update FCM Token on server after login
        await PushNotificationService.updateTokenOnServer();

        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      print('Login error: ${e.response?.data}');
    }
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.dio.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': 'flutter_app',
      });

      if (response.statusCode == 200) {
        String token = response.data['token'];
        _user = User.fromJson(response.data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));

        _isAuthenticated = true;

        // Update FCM Token on server after registration
        await PushNotificationService.updateTokenOnServer();

        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      print('Registration error: ${e.response?.data}');
    }
    return false;
  }

  Future<String?> forgotPassword(String email) async {
    try {
      final response = await _apiService.dio.post('/forgot-password', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        return response.data['message'];
      }
    } on DioException catch (e) {
      print('Forgot password error: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        return e.response?.data['message'];
      }
      if (e.response?.data != null && e.response?.data['errors'] != null && e.response?.data['errors']['email'] != null) {
        return e.response?.data['errors']['email'][0];
      }
    }
    return null;
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? language,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      if (language != null) {
        data['language'] = language;
      }

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
        data['password_confirmation'] = passwordConfirmation;
      }

      final response = await _apiService.dio.put('/profile', data: data);

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      print('Update profile error: ${e.response?.data}');
    }
    return false;
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.dio.get('/profile');
      if (response.statusCode == 200) {
        // Die API gibt das User-Objekt direkt zurück oder in einem 'user' Feld
        final userData = response.data['user'] ?? response.data;
        _user = User.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } on DioException catch (e) {
      print('Fetch profile error: ${e.response?.data}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      notifyListeners();
    }
  }

  Future<void> tryAutoLogin() async {
    if (!_isInitializing) {
      _isInitializing = true;
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      _isAuthenticated = true;

      // Update FCM Token on server after auto-login
      PushNotificationService.updateTokenOnServer();
    }

    _isInitializing = false;
    notifyListeners();
  }
}
