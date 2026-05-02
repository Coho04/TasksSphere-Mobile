class TaskList {
  final int id;
  final String title;
  final String? description;
  final String type; // 'tasks' or 'checklist'
  final String? icon;
  final String? color;
  final int position;
  final int itemCount;
  final int completedCount;

  TaskList({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.icon,
    this.color,
    this.position = 0,
    this.itemCount = 0,
    this.completedCount = 0,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'] ?? 'checklist',
      icon: json['icon'],
      color: json['color'],
      position: json['position'] ?? 0,
      itemCount: (json['items'] as List?)?.length ??
          (json['tasks'] as List?)?.length ??
          0,
      completedCount: (json['items'] as List?)
              ?.where((i) => i['is_completed'] == true)
              .length ??
          (json['tasks'] as List?)
              ?.where((t) => t['completed_at'] != null)
              .length ??
          0,
    );
  }
}
