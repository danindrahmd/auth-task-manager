import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskInput extends StatefulWidget {
  final Function(String, DateTime, TimeOfDay, TimeOfDay) onSubmit;

  const TaskInput({Key? key, required this.onSubmit, required void Function(String taskTitle, DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime) onAddTask}) : super(key: key);

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final TextEditingController _taskController = TextEditingController();
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _startTime = TimeOfDay.now();
  late TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(Duration(hours: 1)),
  );

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

  void _submitTask() {
    final taskTitle = _taskController.text;
    if (taskTitle.isNotEmpty) {
      widget.onSubmit(
        taskTitle,
        _selectedDate,
        _startTime,
        _endTime,
      );
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _taskController,
          decoration: InputDecoration(
            labelText: 'Add a task',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _submitTask,
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
              height: 40,
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
              height: 40,
              child: TextButton(
                onPressed: () => _selectTime(context, true),
                child: Text('Choose Start Time'),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'End Time: ${_endTime.format(context)}',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: () => _selectTime(context, false),
                child: Text('Choose End Time'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
