import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeInput extends StatefulWidget {
  final String label;
  final DateTime initialDateTime;
  final void Function(DateTime) onDateTimeChanged;

  const DateTimeInput({
    Key? key,
    required this.label,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '${widget.label}: ${DateFormat.yMMMd().format(_selectedDateTime)}',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => _selectDateTime(context),
          child: Text('Choose ${widget.label}'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDateTime != null && pickedDateTime != _selectedDateTime) {
      setState(() {
        _selectedDateTime = pickedDateTime;
      });
      widget.onDateTimeChanged(_selectedDateTime);
    }
  }
}
