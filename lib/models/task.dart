class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? plannedAt; // Für Occurrences
  final bool isActive;
  final bool isArchived;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueAt,
    this.completedAt,
    this.plannedAt,
    required this.isActive,
    required this.isArchived,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json.containsKey('task') ? json['task'] : json;
    final String? plannedAtStr = json.containsKey('planned_at') ? json['planned_at'] : data['planned_at'];

    return Task(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      dueAt: data['due_at'] != null ? DateTime.parse(data['due_at']) : null,
      completedAt: data['completed_at'] != null ? DateTime.parse(data['completed_at']) : null,
      plannedAt: plannedAtStr != null ? DateTime.parse(plannedAtStr) : null,
      isActive: data['is_active'] == 1 || data['is_active'] == true,
      isArchived: data['is_archived'] == 1 || data['is_archived'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_at': dueAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'planned_at': plannedAt?.toIso8601String(),
      'is_active': isActive,
      'is_archived': isArchived,
    };
  }
}
