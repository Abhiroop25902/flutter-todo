import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'models/todo_page.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  const TodoCard({super.key, required this.todo});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        horizontalTitleGap: 0,
        leading: Checkbox(
          checkColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircleBorder(),
          activeColor: Theme.of(context).colorScheme.primary,
          value: widget.todo.done,
          side: BorderSide(
              color: Theme.of(context).unselectedWidgetColor, width: 1.5),
          onChanged: (value) => {
            setState(
              () {
                widget.todo.done = value!;

                if (value) {
                  Provider.of<TodoPage>(context, listen: false)
                      .removeTodo(widget.todo);
                  Provider.of<TodoPage>(context, listen: false)
                      .addCompletedTodo(widget.todo);
                } else {
                  Provider.of<TodoPage>(context, listen: false)
                      .removeCompletedTodo(widget.todo);
                  Provider.of<TodoPage>(context, listen: false)
                      .addTodo(widget.todo);
                }
              },
            )
          },
        ),
        title: Text(
          widget.todo.title,
          style: TextStyle(
              decoration: widget.todo.done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none),
        ),
      ),
    );
  }
}
