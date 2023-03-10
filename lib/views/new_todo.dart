import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../models/todo_page_list.dart';





class NewTodo extends StatefulWidget {
  const NewTodo({super.key});

  @override
  State<NewTodo> createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  final FocusNode _todoInputFocusNode = FocusNode();
  // final TextEditingController _todoInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_todoInputFocusNode);
    return Card(
      margin: const EdgeInsets.all(2),
      child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.add,
              // size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          horizontalTitleGap: 0,
          title: TextField(
            // controller: _todoInputController,
            focusNode: _todoInputFocusNode,
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (value) {
              Provider.of<TodoPageList>(context, listen: false).currentPage
                  .addTodo(Todo(title: value));
              Navigator.pop(context);
            },
          )),
    );
  }
}
