import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/todo_page.dart';
import 'todo_card.dart';

class CompletedTodos extends StatelessWidget {
  final TodoPage todoPage;

  const CompletedTodos({super.key, required this.todoPage});

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      animationDuration: const Duration(milliseconds: 100),
      children: [
        ExpansionPanelRadio(
            canTapOnHeader: true,
            value: 1,
            headerBuilder: (_, isExpanded) => ListTile(
                    title: Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleLarge,
                )),
            body: Column(
              children: [
                for (var completedTodo in todoPage.completedTodos)
                  TodoCard(
                    todo: completedTodo,
                  )
              ],
            ))
      ],
    );
  }
}
