import 'package:flutter/material.dart';
import 'package:todo_firebase/models/todo.dart';
import 'package:todo_firebase/models/todo_page.dart';

class TodoPageList with ChangeNotifier {
  late List<TodoPage> _todoPages;
  late int _currentPage;

  factory TodoPageList.test() => TodoPageList(
        todoPages: [TodoPage.test()],
      );

  TodoPageList({List<TodoPage>? todoPages, int currentPage = 0}) {
    _todoPages = todoPages ?? [];
    _currentPage = currentPage;
  }

  TodoPage get currentPage => _todoPages[_currentPage];

  void updateCurrentPage({required int newPageIdx}) {
    if (newPageIdx >= _todoPages.length) return;

    _currentPage = newPageIdx;
    notifyListeners();
  }

  void addTodoPage({required String pageName}) {
    _todoPages.add(TodoPage(pageName: pageName));
    _currentPage = _todoPages.length - 1;
    notifyListeners();
  }

  List<TodoPage> get todoPageList => _todoPages; 
}
