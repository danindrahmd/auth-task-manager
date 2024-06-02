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
  final String? description;
  final List<String>? fileUrls;


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
    this.description,
    this.fileUrls,
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
      'description': description,
      'fileUrls': fileUrls,

    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: map['id'] ?? '',
      documentId: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      color: map['color'] != null ? Color(map['color']) : Colors.white,
      description: map['description'],
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
    );
  }

  Task copyWith({
    String? id,
    String? documentId,
    String? userId,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? description,
    List<String>? fileUrls,

  }) {
    return Task(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      description: description ?? this.description,
      fileUrls: fileUrls ?? this.fileUrls,
    );
  }
}
