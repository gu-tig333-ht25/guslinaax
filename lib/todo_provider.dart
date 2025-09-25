import 'package:flutter/material.dart';
import 'todo_api.dart';
import 'main.dart';

//Provider för att ahntera todo-listan och tillståndet i appen
class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String _filter = 'all';

  //Getter för todos, filtrerar beroende på _filter
  List<Todo> get todos {
    if (_filter == 'done') return _todos.where((t) => t.isDone).toList();
    if (_filter == 'undone') return _todos.where((t) => !t.isDone).toList();
    return _todos;
  }

  //Getter för filter
  String get filter => _filter;

  //Sätt filter och notifyListeners så att UI updateras
  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  //Hjälpfunktion för att sortera todos så att done hamnar längst ner i listan
  void _sortTodos() {
    _todos.sort((a, b) {
      if (a.isDone == b.isDone) return 0;
      return a.isDone ? 1 : -1; // isDone=true hamnar sist
    });
  }

  //Ladda todos från API
  Future<void> loadTodos() async {
    try {
      _todos = await TodoApi.fetchTodos(); //hämtar todos från servern
      _sortTodos(); //sorterar så att gjorda todos hamnar sist
      notifyListeners(); //updaterar UI
    } catch (e) {
      print("Failed to load todos: $e");
    }
  }

  //Lägg till ny todo
  Future<void> addTodo(String title) async {
    try {
      _todos = await TodoApi.createTodo(title);
      _sortTodos();
      notifyListeners();
    } catch (e) {
      print("Failed to add todo: $e");
    }
  }

  //Växla isDone-status på en todo
  Future<void> toggleTodo(Todo todo) async {
    try {
      final updated = Todo(
        id: todo.id,
        title: todo.title,
        isDone: !todo.isDone,
      );

      _todos = await TodoApi.updateTodo(updated);
      _sortTodos();
      notifyListeners();
    } catch (e) {
      print("Failed to update todo: $e");
    }
  }
  
  //Ta bort en todo
  Future<void> removeTodo(Todo todo) async {
    if (todo.id == null) return;

    try {
      _todos = await TodoApi.deleteTodo(todo.id!);
      _sortTodos();
      notifyListeners();
    } catch (e) {
      print("Failed to delete todo: $e");
    }
  }
}