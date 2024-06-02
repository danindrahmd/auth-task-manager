import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:modernlogintute/models/task.dart';

class TaskDescriptionPage extends StatefulWidget {
  final Task task;

  TaskDescriptionPage({required this.task});

  @override
  _TaskDescriptionPageState createState() => _TaskDescriptionPageState();
}

class _TaskDescriptionPageState extends State<TaskDescriptionPage> {
  final TextEditingController _descriptionController = TextEditingController();
  late CollectionReference _tasksCollection;
  late User? user;
  bool _isLoading = false;
  List<String> _fileUrls = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _tasksCollection = FirebaseFirestore.instance.collection('users/${user!.uid}/tasks');
    _descriptionController.text = widget.task.description ?? '';
    _fileUrls = widget.task.fileUrls ?? [];
  }

  void _updateDescription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (user != null) {
        final updatedTask = widget.task.copyWith(
          description: _descriptionController.text,
          fileUrls: _fileUrls,
        );
        await _tasksCollection.doc(widget.task.documentId).update(updatedTask.toMap());
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating description: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final file = result.files.single;
        print('File name: ${file.name}');
        print('File size: ${file.size}');

        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }

        final fileName = '${user!.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);

        await ref.putData(file.bytes!);
        String fileUrl = await ref.getDownloadURL();

        setState(() {
          _fileUrls.add(fileUrl);
        });
      } catch (e) {
        print('Error uploading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading file: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due: ${widget.task.dueDate != null ? DateFormat.yMMMd().format(widget.task.dueDate!) : 'No date'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Attached Files:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _fileUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('File ${index + 1}'),
                    subtitle: Text(_fileUrls[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.open_in_new),
                      onPressed: () {
                        // Open file URL in browser or a viewer
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploadFile,
                    child: Text('Upload File'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateDescription,
                    child: Text('Save Description'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
