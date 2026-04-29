import '../models/task.dart';
import '../models/task_completion.dart';
import '../services/api_service.dart';
import 'task_repository.dart';

class CloudTaskRepository implements TaskRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Task>> fetchOccurrences() async {
    final response = await _apiService.dio.get('/tasks/occurrences');
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => Task.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<List<TaskCompletion>> fetchCompleted() async {
    final response = await _apiService.dio.get('/tasks/completed');
    if (response.statusCode == 200) {
      List<dynamic> completedData = response.data;
      return completedData.map((item) => TaskCompletion.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<bool> createTask(String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule, String? recurrenceTimezone}) async {
    try {
      final response = await _apiService.dio.post('/tasks', data: {
        'title': title,
        'description': description,
        'due_at': dueAt?.toIso8601String(),
        'recurrence_rule': recurrenceRule,
        'recurrence_timezone': recurrenceTimezone,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeTask(Task task) async {
    try {
      final response = await _apiService.dio.post('/tasks/${task.id}/complete', data: {
        'planned_at': task.plannedAt?.toIso8601String(),
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
