import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modernlogintute/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'task_description.dart';

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
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  Color _taskColor = Colors.white;  // Task color

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
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
    try {
      final taskTitle = _taskController.text;
      if (taskTitle.isNotEmpty && user != null) {
        final newTask = Task(
          id: Uuid().v4(),
          userId: user!.uid,
          title: taskTitle,
          documentId: '',
          dueDate: _selectedDate,
          startTime: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _startTime.hour,
            _startTime.minute,
          ),
          endTime: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _endTime.hour,
            _endTime.minute,
          ),
          color: _taskColor,  // Save the selected color
        );
        await _tasksCollection.add(newTask.toMap());
        _taskController.clear();
        setState(() {
          _taskColor = Colors.white;  // Reset color after adding task
        });
      } else {
        throw Exception("Task title is empty or user is null");
      }
    } catch (e) {
      print("Error adding task: $e");
      _showErrorDialog("Oops! Something went wrong", "Something went wrong while adding your task. Please make sure you've entered the task title and try again.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        startTime: task.startTime,
        endTime: task.endTime,
        color: task.color,
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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
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

  Future<void> _selectColor(BuildContext context) async {
    Color pickedColor = _taskColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Task Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _taskColor,
              onColorChanged: (color) => pickedColor = color,
              // showLabel: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _taskColor = pickedColor;
                });
                Navigator.pop(context);
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Color _backgroundColor = Colors.transparent;

  Widget _buildEndTimeRow() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: _backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'End Time: ${_endTime.format(context)}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 35,
            child: TextButton(
              onPressed: () => _selectTime(context, false),
              child: Text('Choose End Time'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Tasknizer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleDarkMode,
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            IconButton(onPressed: _confirmSignOut, icon: Icon(Icons.logout)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Add a task (Title)',
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
                  SizedBox(
                    height: 35,
                    child: TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Choose Date'),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Start Time: ${_startTime.format(context)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text('Choose Start Time'),
                    ),
                  ),
                ],
              ),
              _buildEndTimeRow(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Task Color:',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _taskColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton(
                      onPressed: () => _selectColor(context),
                      child: Text('Choose Color'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: user != null
                      ? _tasksCollection.orderBy('dueDate').snapshots()
                      : Stream.empty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final taskDocs = snapshot.data!.docs;
                    final tasks = taskDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Task.fromMap(data, doc.id);
                    }).toList();

                    return _buildTaskList(tasks);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    Map<DateTime?, List<Task>> groupedTasks = {};

    tasks.forEach((task) {
      DateTime? dueDate = task.dueDate;
      if (dueDate != null) {
        DateTime date = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (!groupedTasks.containsKey(date)) {
          groupedTasks[date] = [];
        }
        groupedTasks[date]!.add(task);
      }
    });

    List<DateTime?> sortedKeys = groupedTasks.keys.toList()
      ..sort((a, b) => a!.compareTo(b!));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        DateTime date = sortedKeys[index]!;
        List<Task> tasksForDate = groupedTasks[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tasksForDate.length,
              itemBuilder: (context, index) {
                Task task = tasksForDate[index];
                return _buildTaskTile(task);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    DateTime today = DateTime.now();
    TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return ListTile(
        title: Text(
          'Today',
          style: headerStyle,
        ),
      );
    } else if (date.year == today.year && date.month == today.month && date.day == today.day + 1) {
      return ListTile(
        title: Text(
          'Tomorrow',
          style: headerStyle,
        ),
      );
    } else {
      return ListTile(
        title: Text(
          DateFormat.yMMMd().format(date),
          style: headerStyle,
        ),
      );
    }
  }

  Widget _buildTaskTile(Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDescriptionPage(task: task),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0), // Adjust the radius for smoothness
          child: Container(
            color: task.color,  // Set the background color for each task
            height: 120, // Set a fixed height for the container
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Flexible(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.dueDate != null) Text('Due: ${DateFormat.yMMMd().format(task.dueDate!)}'),
                      if (task.startTime != null && task.endTime != null) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Start: ${DateFormat.jm().format(task.startTime!)}'),
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
                        onPressed: () => _toggleTaskCompletion(task),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task),
                      ),
                    ],
                  ),
                ),
                if (task.startTime != null && task.endTime != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity, // Take up all available width
                          child: LinearProgressIndicator(
                            value: _calculateProgress(task.startTime!, task.endTime!, DateTime.now()),
                            minHeight: 15,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              '${(_calculateProgress(task.startTime!, task.endTime!, DateTime.now()) * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  double _calculateProgress(DateTime startTime, DateTime endTime, DateTime now) {
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
