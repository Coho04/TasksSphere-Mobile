import 'dart:convert';
import '../models/task.dart';
import '../models/task_completion.dart';
import '../services/database_service.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final DatabaseService _db = DatabaseService();

  @override
  Future<List<Task>> fetchOccurrences() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'is_archived = ? AND (completed_at IS NULL OR recurrence_rule IS NOT NULL)',
      whereArgs: [0],
    );

    final List<Task> results = [];
    final now = DateTime.now();
    final end = now.add(const Duration(days: 7));

    for (final map in maps) {
      final task = _taskFromMap(map);
      if (task.recurrenceRule != null && task.recurrenceRule!.isNotEmpty) {
        // For recurring tasks, generate occurrences for next 7 days
        final occurrences = _generateOccurrences(task, now, end);
        results.addAll(occurrences);
      } else {
        results.add(task);
      }
    }

    results.sort((a, b) {
      if (a.plannedAt == null && b.plannedAt == null) return 0;
      if (a.plannedAt == null) return 1;
      if (b.plannedAt == null) return -1;
      return a.plannedAt!.compareTo(b.plannedAt!);
    });

    return results;
  }

  List<Task> _generateOccurrences(Task task, DateTime start, DateTime end) {
    final occurrences = <Task>[];
    if (task.recurrenceRule == null) return occurrences;

    final rule = task.recurrenceRule!;
    final frequency = rule['frequency'] as String? ?? 'daily';
    final interval = (rule['interval'] as num?)?.toInt() ?? 1;

    DateTime current = task.dueAt ?? DateTime.now();

    // If overdue, add one occurrence
    if (current.isBefore(start)) {
      occurrences.add(Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueAt: task.dueAt,
        completedAt: task.completedAt,
        plannedAt: current,
        isActive: task.isActive,
        isArchived: task.isArchived,
        recurrenceRule: task.recurrenceRule,
        recurrenceTimezone: task.recurrenceTimezone,
      ));
      current = _addInterval(current, frequency, interval);
    }

    int limit = 100;
    while (current.isBefore(end) && limit > 0) {
      occurrences.add(Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueAt: task.dueAt,
        completedAt: task.completedAt,
        plannedAt: current,
        isActive: task.isActive,
        isArchived: task.isArchived,
        recurrenceRule: task.recurrenceRule,
        recurrenceTimezone: task.recurrenceTimezone,
      ));
      current = _addInterval(current, frequency, interval);
      limit--;
    }

    return occurrences;
  }

  DateTime _addInterval(DateTime date, String frequency, int interval) {
    switch (frequency) {
      case 'hourly':
        return date.add(Duration(hours: interval));
      case 'daily':
        return date.add(Duration(days: interval));
      case 'weekly':
        return date.add(Duration(days: 7 * interval));
      case 'monthly':
        return DateTime(date.year, date.month + interval, date.day, date.hour, date.minute);
      default:
        return date.add(Duration(days: interval));
    }
  }

  @override
  Future<List<TaskCompletion>> fetchCompleted() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> completionMaps = await db.rawQuery('''
      SELECT tc.*, t.title, t.description, t.due_at, t.is_active, t.is_archived,
             t.recurrence_rule, t.recurrence_timezone
      FROM task_completions tc
      JOIN tasks t ON tc.task_id = t.id
      WHERE tc.is_skipped = 0 AND tc.completed_at IS NOT NULL
      ORDER BY tc.completed_at DESC
      LIMIT 10
    ''');

    return completionMaps.map((map) {
      final task = Task(
        id: map['task_id'] as int,
        title: map['title'] as String,
        description: map['description'] as String?,
        dueAt: map['due_at'] != null ? DateTime.parse(map['due_at'] as String) : null,
        isActive: (map['is_active'] as int) == 1,
        isArchived: (map['is_archived'] as int) == 1,
        recurrenceRule: map['recurrence_rule'] != null
            ? jsonDecode(map['recurrence_rule'] as String) as Map<String, dynamic>
            : null,
        recurrenceTimezone: map['recurrence_timezone'] as String?,
      );
      return TaskCompletion(
        id: map['id'] as int,
        task: task,
        completedAt: DateTime.parse(map['completed_at'] as String),
        plannedAt: map['planned_at'] != null ? DateTime.parse(map['planned_at'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<bool> createTask(String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule, String? recurrenceTimezone}) async {
    try {
      final db = await _db.database;
      final now = DateTime.now().toIso8601String();
      await db.insert('tasks', {
        'title': title,
        'description': description,
        'due_at': dueAt?.toIso8601String(),
        'recurrence_rule': recurrenceRule != null ? jsonEncode(recurrenceRule) : null,
        'recurrence_timezone': recurrenceTimezone,
        'is_active': 1,
        'is_archived': 0,
        'created_at': now,
        'updated_at': now,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completeTask(Task task) async {
    try {
      final db = await _db.database;
      final now = DateTime.now().toIso8601String();

      if (task.recurrenceRule != null && task.recurrenceRule!.isNotEmpty) {
        // Recurring: add completion record
        await db.insert('task_completions', {
          'task_id': task.id,
          'planned_at': task.plannedAt?.toIso8601String(),
          'completed_at': now,
          'is_skipped': 0,
        });
      } else {
        // Non-recurring: mark task as completed
        await db.update(
          'tasks',
          {'completed_at': now, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [task.id],
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper: convert SQLite map to Task
  Task _taskFromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueAt: map['due_at'] != null ? DateTime.parse(map['due_at'] as String) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      plannedAt: map['due_at'] != null ? DateTime.parse(map['due_at'] as String) : null,
      isActive: (map['is_active'] as int) == 1,
      isArchived: (map['is_archived'] as int) == 0 ? false : true,
      recurrenceRule: map['recurrence_rule'] != null
          ? jsonDecode(map['recurrence_rule'] as String) as Map<String, dynamic>
          : null,
      recurrenceTimezone: map['recurrence_timezone'] as String?,
    );
  }

  @override
  Future<bool> updateTask(int taskId, String title, String? description, DateTime? dueAt,
      {Map<String, dynamic>? recurrenceRule, String? recurrenceTimezone}) async {
    try {
      final db = await _db.database;
      await db.update('tasks', {
        'title': title,
        'description': description,
        'due_at': dueAt?.toIso8601String(),
        'recurrence_rule': recurrenceRule != null ? jsonEncode(recurrenceRule) : null,
        'recurrence_timezone': recurrenceTimezone,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [taskId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteTask(int taskId) async {
    try {
      final db = await _db.database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all tasks as raw maps (for migration to cloud)
  Future<List<Map<String, dynamic>>> getAllTasksRaw() async {
    final db = await _db.database;
    return await db.query('tasks');
  }

  /// Get all task lists as raw maps (for migration)
  Future<List<Map<String, dynamic>>> getAllTaskListsRaw() async {
    final db = await _db.database;
    return await db.query('task_lists');
  }

  /// Get all list items as raw maps (for migration)
  Future<List<Map<String, dynamic>>> getAllListItemsRaw() async {
    final db = await _db.database;
    return await db.query('list_items');
  }
}
