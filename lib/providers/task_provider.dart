import 'package:flutter/material.dart';
import 'package:student_task_manager_app/models/task_model.dart';
import 'package:student_task_manager_app/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    final List<TaskModel> fetchedTasks = await _taskService.getAllTasksOnce(userId);
    _tasks
      ..clear()
      ..addAll(fetchedTasks);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> removeTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Future<void> refreshTasks(String userId) async {
    await loadTasks(userId);
  }
}
