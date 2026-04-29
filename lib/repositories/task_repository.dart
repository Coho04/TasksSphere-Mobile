import '../models/task.dart';
import '../models/task_completion.dart';

abstract class TaskRepository {
  Future<List<Task>> fetchOccurrences();
  Future<List<TaskCompletion>> fetchCompleted();
  Future<bool> createTask(String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule, String? recurrenceTimezone});
  Future<bool> completeTask(Task task);
}
