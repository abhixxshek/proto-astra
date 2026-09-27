import 'package:flutter/foundation.dart';
import '../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [
    TaskModel(
      id: 't1',
      title: 'Apply 1st Split Urea Dose (Wheat Crop)',
      category: 'Fertilizer',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      isCompleted: false,
    ),
    TaskModel(
      id: 't2',
      title: 'Drip Irrigation Schedule (2 Hours Evening)',
      category: 'Irrigation',
      priority: 'Medium',
      dueDate: DateTime.now(),
      isCompleted: true,
    ),
    TaskModel(
      id: 't3',
      title: 'Inspect Cotton Leaves for Aphids / Sucking Pests',
      category: 'Spraying',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      isCompleted: false,
    ),
  ];

  List<TaskModel> get tasks => _tasks;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  void addTask({
    required String title,
    required String category,
    required String priority,
    required DateTime dueDate,
  }) {
    _tasks.add(TaskModel(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
    ));
    notifyListeners();
  }

  void toggleTaskStatus(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }
}
