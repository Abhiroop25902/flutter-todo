import 'todo.dart';

class TodoPage  {
  factory TodoPage.test() {
    return TodoPage(todos: [
      Todo(title: 'Water Plants'),
      Todo(title: 'Ikea Delivery'),
      Todo(title: 'Duct Tape'),
      Todo(title: 'Decide where to go for the family summer camp'),
    ], completedTodos: [
      Todo(title: 'Yoga with Sofie', done: true),
    ]);
  }

  TodoPage(
      {this.pageName = "Tasks",
      List<Todo>? todos,
      List<Todo>? completedTodos}) {
    _todos = todos ?? [];
    _completedTodos = completedTodos ?? [];
  }

  final String pageName;

  late List<Todo> _todos;

  late List<Todo> _completedTodos;

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
  }

  void removeTodo(Todo todo) {
    _todos.remove(todo);
  }

  void addCompletedTodo(Todo todo) {
    _completedTodos.insert(0, todo);
  }

  void removeCompletedTodo(Todo todo) {
    _completedTodos.remove(todo);
  }

  List<Todo> get todos {
    return _todos;
  }

  List<Todo> get completedTodos {
    return _completedTodos;
  }
}
