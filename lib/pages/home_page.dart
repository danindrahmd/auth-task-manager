import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modernlogintute/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  late DateTime _selectedDate;
  late User? user;
  late CollectionReference _tasksCollection;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initialize();
  }

  Future<void> _initialize() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _tasksCollection = FirebaseFirestore.instance.collection('users/${user!.uid}/tasks');
    }
  }

  void _signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _confirmSignOut() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _signUserOut();
    }
  }

  void _addTask() async {
    final taskTitle = _taskController.text;
    if (taskTitle.isNotEmpty && user != null) {
      final newTask = Task(
        id: Uuid().v4(),
        userId: user!.uid,
        title: taskTitle,
        documentId: '',
        dueDate: _selectedDate, // Include the selected due date
      );
      await _tasksCollection.add(newTask.toMap());
      _taskController.clear();
    }
  }

  void _toggleTaskCompletion(Task task) async {
    if (user != null) {
      final updatedTask = Task(
        id: task.id,
        documentId: task.documentId,
        userId: user!.uid,
        title: task.title,
        isCompleted: !task.isCompleted,
        dueDate: task.dueDate,
      );
      await _tasksCollection.doc(task.documentId).update(updatedTask.toMap());
    }
  }

  void _deleteTask(Task task) async {
    if (user != null) {
      await _tasksCollection.doc(task.documentId).delete();
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tasknizer'),
          actions: [
            IconButton(
              onPressed: _toggleDarkMode,
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            IconButton(onPressed: _confirmSignOut, icon: Icon(Icons.logout)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Add a task',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTask,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Due Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choose Date'),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: user != null ? _tasksCollection.snapshots() : Stream.empty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final taskDocs = snapshot.data!.docs;
                    final tasks = taskDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Task.fromMap(data, doc.id);
                    }).toList();

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration:
                              task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          subtitle: task.dueDate != null
                              ? Text('Due: ${DateFormat.yMMMd().format(task.dueDate!)}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () => _toggleTaskCompletion(task),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteTask(task),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
