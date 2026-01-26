import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/push_notification_service.dart';
import 'package:dio/dio.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  TaskProvider() {
    _initNotificationListener();
  }

  void _initNotificationListener() {
    PushNotificationService.onMessageStream.listen((message) {
      print("TaskProvider: Received message, fetching tasks...");
      fetchTasks();
    });
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/tasks/occurrences');
      if (response.statusCode == 200) {
        print(response.data);
        List<dynamic> data = response.data;
        _tasks = data.map((item) => Task.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      print('Fetch tasks error: ${e.response?.data}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeTask(Task task) async {
    try {
      final response = await _apiService.dio.post('/tasks/${task.id}/complete', data: {
        'planned_at': task.plannedAt?.toIso8601String(),
      });
      if (response.statusCode == 200) {
        _tasks.removeWhere((t) => t.id == task.id && t.plannedAt == task.plannedAt);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Complete task error: $e');
    }
    return false;
  }

  Future<bool> createTask(String title, String? description, DateTime? dueAt) async {
    try {
      final response = await _apiService.dio.post('/tasks', data: {
        'title': title,
        'description': description,
        'due_at': dueAt?.toIso8601String(),
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchTasks();
        return true;
      }
    } catch (e) {
      print('Create task error: $e');
    }
    return false;
  }
}
