class TaskModel {
  final String id;
  final String title;
  final String category;
  final String priority;
  final DateTime dueDate;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });
}
