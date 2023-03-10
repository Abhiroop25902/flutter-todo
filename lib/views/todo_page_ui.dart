import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:random_color/random_color.dart";
import "package:todo_firebase/models/todo.dart";
import "package:todo_firebase/models/todo_page_list.dart";

import "../../models/current_user.dart";
import "../../models/todo_page.dart";
import "new_page_alert.dart";
import 'new_todo.dart';

class TodoPageUI extends StatefulWidget {
  final TodoPage todoPage;

  const TodoPageUI({super.key, required this.todoPage});

  @override
  State<TodoPageUI> createState() => _TodoPageUIState();
}

class _TodoPageUIState extends State<TodoPageUI> {
  ListTile _getCurrentUserInfoTile(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).currentUser;

    if (currentUser == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.person_add,
          ),
        ),
        title: Text(
          "Log In",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => Navigator.pushNamed(context, '/sign-in'),
      );
    }

    // now user is signed in
    final String? userPhotoUrl = currentUser.photoURL;
    final String? userDisplayName = currentUser.displayName;

    if (userPhotoUrl == null && userDisplayName == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: IconButton(
            onPressed: () => showLogOutDialog(context),
            icon: const Icon(Icons.person),
          ),
        ),
        title: Text(
          currentUser.email!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => showLogOutDialog(context),
      );
    }

    if (userPhotoUrl == null && userDisplayName != null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: RandomColor().randomColor(
              colorBrightness:
                  Theme.of(context).brightness == ThemeData().brightness
                      ? ColorBrightness.light
                      : ColorBrightness.dark),
          child: Text(userDisplayName.split(' ').map((s) => s[0]).join(""),
              style: Theme.of(context).textTheme.bodyLarge),
        ),
        title: Text(
          userDisplayName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => showLogOutDialog(context),
      );
    }

    if (userPhotoUrl != null && userDisplayName == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userPhotoUrl),
          child: GestureDetector(
            onTap: () => showLogOutDialog(context),
          ),
        ),
        title: Text(
          currentUser.email!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => showLogOutDialog(context),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userPhotoUrl!),
        child: GestureDetector(
          onTap: () => showLogOutDialog(context),
        ),
      ),
      title: Text(
        currentUser.displayName!,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      onTap: () => showLogOutDialog(context),
    );
  }

  void showLogOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirm Log Out?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Provider.of<CurrentUser>(context, listen: false)
                          .signOut();
                      Navigator.pop(context);
                    },
                    child: const Text('Log Out')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'))
              ],
            ));
  }

  Drawer _getAppDrawer(BuildContext context) {
    return Drawer(
        child: SafeArea(
      child: Column(
        children: [
          _getCurrentUserInfoTile(context),
          Expanded(
            child: ListView.builder(
              itemCount: Provider.of<TodoPageList>(context).todoPageList.length,
              itemBuilder: (context, idx) {
                String pageName = Provider.of<TodoPageList>(context)
                    .todoPageList[idx]
                    .pageName;

                return ListTile(
                  minLeadingWidth: 0,
                  style: ListTileStyle.drawer, //       leading: Icon(
                  leading: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(pageName),
                  onTap: () {
                    Provider.of<TodoPageList>(context, listen: false)
                        .updateCurrentPage(newPageIdx: idx);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          Card(
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
                title: Text(
                  'Add a page',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                onTap: () async {
                  String? newPageName = await showDialog<String>(
                      context: context, builder: (context) => newPageAlert());

                  if (newPageName == null) return;

                  Provider.of<TodoPageList>(context, listen: false)
                      .addTodoPage(pageName: newPageName);
                }),
          )
        ],
      ),
    ));
  }

  Card _getTodoCard({required Todo todo}) {
    return Card(
      margin: const EdgeInsets.all(2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        horizontalTitleGap: 0,
        leading: Checkbox(
          checkColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircleBorder(),
          activeColor: Theme.of(context).colorScheme.primary,
          value: todo.done,
          side: BorderSide(
              color: Theme.of(context).unselectedWidgetColor, width: 1.5),
          onChanged: (value) => {
            setState(
              () {
                todo.done = value!;

                if (value) {
                  setState(() {
                    widget.todoPage.removeTodo(todo);
                    widget.todoPage.addCompletedTodo(todo);
                  });
                } else {
                  setState(() {
                    widget.todoPage.removeCompletedTodo(todo);
                    widget.todoPage.addTodo(todo);
                  });
                }
              },
            )
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
              decoration:
                  todo.done ? TextDecoration.lineThrough : TextDecoration.none),
        ),
      ),
    );
  }

  Widget _getCompletedTodoList() {
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
                for (var completedTodo in widget.todoPage.completedTodos)
                  _getTodoCard(
                    todo: completedTodo,
                  )
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _getAppDrawer(context),
      appBar: AppBar(
        title: Text(
          widget.todoPage.pageName,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var todo in widget.todoPage.todos)
                      _getTodoCard(todo: todo),
                    if (widget.todoPage.completedTodos.isNotEmpty)
                      _getCompletedTodoList(),
                  ],
                ),
              ),
            ),
            Card(
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
                title: Text(
                  'Add a task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: const NewTodo(),
                        )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
