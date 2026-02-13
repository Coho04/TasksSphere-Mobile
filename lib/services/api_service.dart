import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token abgelaufen oder ungültig
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          onUnauthorized?.call();
        }
        return handler.next(e);
      },
    ));
  }

  final Dio _dio = Dio();
  VoidCallback? onUnauthorized;

  // Hinweis: In der Produktion sollte dies konfigurierbar sein.
  final String baseUrl = 'https://tasks.code-sphere.de/api';

  Dio get dio => _dio;
}
