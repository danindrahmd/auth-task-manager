// lib/models/task.dart
class Task {
  final String id;
  final String documentId;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate; // New field for due date

  Task({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate, // Initialize due date field
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Include user ID in the map
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? dueDate!.toIso8601String() : null,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: map['id'],
      documentId: documentId,
      userId: map['userId'], // Retrieve user ID from map
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,

    );
  }
}
