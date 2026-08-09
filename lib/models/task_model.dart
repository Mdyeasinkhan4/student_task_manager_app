import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    this.userId = '',
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Named constructor for creating a new task
  TaskModel.create({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String subject,
    required DateTime dueDate,
    required String priority,
  })  : id = id,
        userId = userId,
        title = title,
        description = description,
        subject = subject,
        dueDate = dueDate,
        priority = priority,
        isCompleted = false,
        createdAt = DateTime.now();

  // Named constructor from Firestore
  TaskModel.fromMap(Map<String, dynamic> map, {required String id})
      : id = id,
        userId = map['userId'] ?? '',
        title = map['title'] ?? '',
        description = map['description'] ?? '',
        subject = map['subject'] ?? '',
        dueDate = (map['dueDate'] as Timestamp).toDate(),
        priority = map['priority'] ?? 'Low',
        isCompleted = map['isCompleted'] ?? false,
        createdAt = map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // copyWith for updating specific fields
  TaskModel copyWith({
    String? title,
    String? description,
    String? subject,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  bool get isPending => !isCompleted;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
}
