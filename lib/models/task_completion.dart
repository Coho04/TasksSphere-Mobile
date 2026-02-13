import 'task.dart';

class TaskCompletion {
  final int id;
  final Task task;
  final DateTime completedAt;
  final DateTime? plannedAt;

  TaskCompletion({
    required this.id,
    required this.task,
    required this.completedAt,
    this.plannedAt,
  });

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'],
      task: Task.fromJson(json['task']),
      completedAt: DateTime.parse(json['completed_at']),
      plannedAt: json['planned_at'] != null ? DateTime.parse(json['planned_at']) : null,
    );
  }
}
