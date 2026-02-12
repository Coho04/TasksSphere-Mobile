import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();
  
  // Hinweis: In der Produktion sollte dies konfigurierbar sein.
  final String baseUrl = 'https://tasks.code-sphere.de/api';

  ApiService() {
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
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
