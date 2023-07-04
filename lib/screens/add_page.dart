import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import 'package:http/http.dart' as http;
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add todo'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(hintText: 'title'),

        ),
        SizedBox(height: 20,),
        TextField(
          controller: descriptonController,
          decoration: InputDecoration(hintText: 'Descripton'),
          keyboardType: TextInputType.multiline,
          minLines: 5,
          maxLines: 8,
        ),
        SizedBox(height: 20,),
        ElevatedButton(onPressed: submitData,
        child: Text('Submit'),)
      ],),
    );
    
  }
  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptonController.text;
    final body = {
  "title": title,
  "description": description,
  "is_completed": false
};
final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
final uri = Uri.parse(url);
final respone = await http.post(uri, body: jsonEncode(body),
headers: {'Content-Type': 'application/json'});
if (respone.statusCode == 201) {
  print('success');
  showSuccessMessenger('Creating Success');
} else {
  print('failed');
  print(respone.body);
}


  
  }
  void showSuccessMessenger(String messenger){
  final snackBar = SnackBar(content: Text(messenger));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}