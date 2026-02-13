import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_completion.dart';
import '../services/api_service.dart';
import '../services/push_notification_service.dart';
import 'package:dio/dio.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<TaskCompletion> _completedTasks = [];
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
  List<TaskCompletion> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/tasks/occurrences');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _tasks = data.map((item) => Task.fromJson(item)).toList();
      }

      final completedResponse = await _apiService.dio.get('/tasks/completed');
      if (completedResponse.statusCode == 200) {
        List<dynamic> completedData = completedResponse.data;
        _completedTasks = completedData.map((item) => TaskCompletion.fromJson(item)).toList();
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
        await fetchTasks(); // Neu laden, um completedTasks zu aktualisieren
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
