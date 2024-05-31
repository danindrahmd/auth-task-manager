// lib/models/task.dart
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String documentId;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final Color color;

  Task({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.startTime,
    this.endTime,
    this.color = Colors.white, // Default color
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
      'color': color.value,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    final String id = map['id'] ?? '';  // Provide a default value or handle null
    return Task(
      id: id,
      documentId: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      color: map['color'] != null ? Color(map['color']) : Colors.white,
    );
  }
}
