import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.dueDate != null)
                Text('Due: ${DateFormat.yMMMd().format(task.dueDate!)}'),
              if (task.startTime != null && task.endTime != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Start: ${DateFormat.jm().format(task.startTime!)}'),
                    SizedBox(width: 10),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _calculateProgress(
                            task.startTime!, task.endTime!, DateTime.now()),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('End: ${DateFormat.jm().format(task.endTime!)}'),
                  ],
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {}, // Implement task completion logic
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {}, // Implement task deletion logic
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateProgress(
      DateTime startTime, DateTime endTime, DateTime now) {
    if (now.isBefore(startTime)) {
      return 0.0;
    } else if (now.isAfter(endTime)) {
      return 1.0;
    } else {
      double totalDuration = endTime.difference(startTime).inSeconds.toDouble();
      double currentDuration = now.difference(startTime).inSeconds.toDouble();
      return currentDuration / totalDuration;
    }
  }
}
