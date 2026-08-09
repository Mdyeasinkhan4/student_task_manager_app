import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_task_manager_app/core/constants/app_constants.dart';
import 'package:student_task_manager_app/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference get _tasksRef =>
      _firestore.collection(AppConstants.tasksCollection);

  /// Add a new task
  Future<TaskModel> addTask({
    required String userId,
    required String title,
    required String description,
    required String subject,
    required DateTime dueDate,
    required String priority,
  }) async {
    final id = _uuid.v4();
    final task = TaskModel.create(
      id: id,
      userId: userId,
      title: title,
      description: description,
      subject: subject,
      dueDate: dueDate,
      priority: priority,
    );

    await _tasksRef.doc(id).set(task.toMap());
    return task;
  }

  /// Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  /// Toggle task completion
  Future<void> toggleComplete(TaskModel task) async {
    await _tasksRef.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  /// Real-time stream of all tasks for a user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  /// Get tasks filtered by completion status
  Stream<List<TaskModel>> getTasksByStatus(String userId, {required bool isCompleted}) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: isCompleted)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  /// Get tasks filtered by priority
  Stream<List<TaskModel>> getTasksByPriority(String userId, String priority) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .where('priority', isEqualTo: priority)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  /// Get task counts for home screen
  Future<Map<String, int>> getTaskCounts(String userId) async {
    final snapshot = await _tasksRef
        .where('userId', isEqualTo: userId)
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
        .toList();

    return {
      'total': tasks.length,
      'pending': tasks.where((t) => !t.isCompleted).length,
      'completed': tasks.where((t) => t.isCompleted).length,
    };
  }

  /// One-time fetch of all tasks (for search)
  Future<List<TaskModel>> getAllTasksOnce(String userId) async {
    final snapshot = await _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromMap(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            ))
        .toList();
  }
}
