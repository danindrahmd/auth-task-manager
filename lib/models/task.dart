// lib/models/task.dart
class Task {
  final String id;
  final String documentId;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate; // New field for due date
  final DateTime? startTime;
  final DateTime? endTime;

  Task({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate, // Initialize due date field
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? dueDate!.toIso8601String() : null,
      'startTime': startTime != null ? startTime!.toIso8601String() : null,
      'endTime': endTime != null ? endTime!.toIso8601String() : null,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: map['id'],
      documentId: documentId,
      userId: map['userId'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    );
  }

}
