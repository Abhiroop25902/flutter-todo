import 'package:flutter/material.dart';

class Todo {
  String title;
  bool done;

  Todo({required this.title, this.done = false});
}

class Todos with ChangeNotifier {
  final List<Todo> _todos = [
    Todo(title: 'Water Plants'),
    Todo(title: 'Ikea Delivery'),
    Todo(title: 'Duct Tape'),
    Todo(title: 'Decide where to go for the family summer camp'),
  ];

  final List<Todo> _completedTodos = [
    Todo(title: 'Yoga with Sofie', done: true),
  ];

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
    notifyListeners();
  }

  void removeTodo(Todo todo) {
    _todos.remove(todo);
    notifyListeners();
  }

  void addCompletedTodo(Todo todo) {
    _completedTodos.insert(0, todo);
    notifyListeners();
  }

  void removeCompletedTodo(Todo todo) {
    _completedTodos.remove(todo);
    notifyListeners();
  }

  List<Todo> get todos {
    return _todos;
  }

  List<Todo> get completedTodos {
    return _completedTodos;
  }
}
