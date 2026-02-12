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
    _isInitializing = true;
    notifyListeners();
    
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
