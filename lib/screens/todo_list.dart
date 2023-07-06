import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/add_page.dart';

class TodoListPage extends StatefulWidget {
  final Map? todo;
  const TodoListPage({super.key, this.todo});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List<dynamic> items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
          centerTitle: true,
        ),
        body: Visibility(
          visible: isLoading,
          child: Center(
            child: CircularProgressIndicator(),
          ),
          replacement: RefreshIndicator(
            onRefresh: fetchTodo,
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                child: Text(
                  'No Items',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(item['title']),
                        subtitle: Text(item['description']),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              //open edit menu
                              navigateToEditPage(item);
                            } else if (value == 'delete') {
                              //delete and refresh the item
                              deleteById(id);
                            }
                          },
                          icon: Transform.rotate(
                            angle:
                                1.5708, // Góc xoay 90 độ (90 độ = pi/2 radian)
                            child: Icon(Icons.more_vert),
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                child: Text('edit'),
                                value: 'edit',
                              ),
                              PopupMenuItem(
                                child: Text('delete'),
                                value: 'delete',
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: const Text('Add Todo'),
        ));
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    //TODO Loading page
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  //TODO API Delete
  Future<void> deleteById(String id) async {
    //Delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final respone = await http.delete(uri);

    if (respone.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage('success');
    } else {
      showErrowMessage('fail');
    }
    // Remove item from the list
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['items'] as List<dynamic>;

      setState(() {
        items = result;
      });
    }
    //print(response.statusCode);
    //print(response.body);
    setState(() {
      isLoading = false;
    });
  }

  void showErrowMessage(String messenger) {
    final snackBar = SnackBar(
      content:
          Text(messenger, style: TextStyle(fontSize: 16, color: Colors.white)),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}
