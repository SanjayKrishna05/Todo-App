import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        "Todo",
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          _messagesListView(),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    return Expanded(
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(
              child: Text(
                "Add a todo!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index].data();
              String todoId = todos[index].id;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        Todo updatedTodo = todo.copyWith(
                          isDone: value ?? false,
                          updatedOn: Timestamp.now(),
                        );
                        _databaseService.updateTodo(todoId, updatedTodo);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      todo.task,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight:
                        todo.isDone ? FontWeight.w400 : FontWeight.w600,
                        color: todo.isDone
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat("dd-MM-yyyy h:mm a").format(
                        todo.updatedOn.toDate(),
                      ),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _databaseService.deleteTodo(todoId);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ];
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
                    onTap: () {
                      // Optional: Handle item tap (e.g., navigate to details or edit screen)
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add a Todo',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: "Enter your task here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Add'),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  Todo todo = Todo(
                    task: _textEditingController.text,
                    isDone: false,
                    createdOn: Timestamp.now(),
                    updatedOn: Timestamp.now(),
                  );
                  _databaseService.addTodo(todo);
                  Navigator.pop(context);
                  _textEditingController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
