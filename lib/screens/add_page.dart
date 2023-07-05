import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptonController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptonController.text = description;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add todo'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'title'),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptonController,
            decoration: InputDecoration(hintText: 'Descripton'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(isEdit ? 'Update' : 'Submit'),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('không thể gọi data');
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptonController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    //submit update data to the sever
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final respone = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show success and fail message
    if (respone.statusCode == 200) {
      showSuccessMessage('Updation Success');
    } else {
      showErrowMessage('Updation Failed');
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptonController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    //submit data to the sever
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final respone = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (respone.statusCode == 201) {
      titleController.text = '';
      descriptonController.text = '';
      print('success');
      showSuccessMessage('Creating Success');
    } else {
      showErrowMessage('Creation Failed');
    }
  }

  void showSuccessMessage(String messenger) {
    final snackBar = SnackBar(
      content: Text(
        messenger,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrowMessage(String messenger) {
    final snackBar = SnackBar(
      content:
          Text(messenger, style: TextStyle(fontSize: 16, color: Colors.white)),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
