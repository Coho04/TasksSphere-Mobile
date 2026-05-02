class ListItem {
  final int id;
  final int taskListId;
  final String title;
  final String? note;
  final bool isCompleted;
  final int position;

  ListItem({
    required this.id,
    required this.taskListId,
    required this.title,
    this.note,
    this.isCompleted = false,
    this.position = 0,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'],
      taskListId: json['task_list_id'],
      title: json['title'],
      note: json['note'],
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      position: json['position'] ?? 0,
    );
  }
}
