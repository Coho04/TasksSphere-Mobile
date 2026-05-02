import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_completion.dart';
import '../repositories/task_repository.dart';
import '../repositories/cloud_task_repository.dart';
import '../repositories/local_task_repository.dart';
import '../services/push_notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<TaskCompletion> _completedTasks = [];
  bool _isLoading = false;
  TaskRepository _repository = CloudTaskRepository();
  bool _isLocalMode = false;

  TaskProvider() {
    _initNotificationListener();
  }

  void _initNotificationListener() {
    PushNotificationService.onMessageStream.listen((message) {
      debugPrint("TaskProvider: Received message, fetching tasks...");
      fetchTasks();
    });
  }

  void setLocalMode() {
    _repository = LocalTaskRepository();
    _isLocalMode = true;
    notifyListeners();
  }

  void setCloudMode() {
    _repository = CloudTaskRepository();
    _isLocalMode = false;
    notifyListeners();
  }

  bool get isLocalMode => _isLocalMode;
  List<Task> get tasks => _tasks;
  List<TaskCompletion> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _repository.fetchOccurrences();
      _completedTasks = await _repository.fetchCompleted();
    } catch (e) {
      debugPrint('Fetch tasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeTask(Task task) async {
    try {
      final success = await _repository.completeTask(task);
      if (success) {
        _tasks.removeWhere((t) => t.id == task.id && t.plannedAt == task.plannedAt);
        await fetchTasks();
        return true;
      }
    } catch (e) {
      debugPrint('Complete task error: $e');
    }
    return false;
  }

  Future<bool> createTask(String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule,
      String? recurrenceTimezone}) async {
    try {
      final success = await _repository.createTask(title, description, dueAt,
          recurrenceRule: recurrenceRule, recurrenceTimezone: recurrenceTimezone);
      if (success) {
        await fetchTasks();
        return true;
      }
    } catch (e) {
      debugPrint('Create task error: $e');
    }
    return false;
  }

  Future<bool> updateTask(int taskId, String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule, String? recurrenceTimezone}) async {
    try {
      final success = await _repository.updateTask(taskId, title, description, dueAt,
          recurrenceRule: recurrenceRule, recurrenceTimezone: recurrenceTimezone);
      if (success) {
        await fetchTasks();
        return true;
      }
    } catch (e) {
      debugPrint('Update task error: $e');
    }
    return false;
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      final success = await _repository.deleteTask(taskId);
      if (success) {
        await fetchTasks();
        return true;
      }
    } catch (e) {
      debugPrint('Delete task error: $e');
    }
    return false;
  }
}
