import 'package:flutter/material.dart';

class Todo {
  String title;
  bool done;

  Todo({required this.title, this.done = false});
}

class Todos with ChangeNotifier {
  final List<Todo> _todos = [
    Todo(title: 'Yoga with Sofie', done: true),
    Todo(title: 'Water Plants'),
    Todo(title: 'Ikea Delivery'),
    Todo(title: 'Duct Tape'),
    Todo(title: 'Decide where to go for the family summer camp'),
  ];

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
    notifyListeners();
  }

  List<Todo> get todos {
    return _todos;
  }
}
