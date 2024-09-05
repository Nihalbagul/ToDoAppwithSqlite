import 'dart:collection';
import 'package:flutter/material.dart';
import '../model/todo_model.dart';
import '../services/database_service.dart';

enum SortCriterion { priority, dueDate, creationDate }

class TodoProvider with ChangeNotifier {
  List<TodoModel> _tasks = [];
  SortCriterion _sortCriterion = SortCriterion.creationDate;
  bool _isAscending = true;
  String _searchQuery = '';

  TodoProvider() {
    _loadTasksFromDb(); // Load tasks when provider is initialized
  }

  UnmodifiableListView<TodoModel> get allTasks {
    List<TodoModel> filteredTasks = _tasks
        .where((task) =>
            task.todoTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (task.description != null &&
                task.description!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();

    filteredTasks.sort((a, b) {
      int comparison;
      switch (_sortCriterion) {
        case SortCriterion.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case SortCriterion.dueDate:
          comparison = (a.dueDate ?? DateTime(2101))
              .compareTo(b.dueDate ?? DateTime(2101));
          break;
        case SortCriterion.creationDate:
        default:
          comparison = a.creationDate.compareTo(b.creationDate);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
    return UnmodifiableListView(filteredTasks);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortCriterion(SortCriterion criterion) {
    _sortCriterion = criterion;
    notifyListeners();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  Future<void> addTask(String task,
      {String? description,
      PriorityLevel priority = PriorityLevel.medium,
      DateTime? dueDate,
      TimeOfDay? reminder}) async {
    final newTask = TodoModel(
      todoTitle: task,
      description: description,
      priority: priority,
      dueDate: dueDate,
      reminder: reminder,
    );
    await DatabaseService().insertTodo(newTask);
    _loadTasksFromDb(); // Refresh tasks after adding
  }

  Future<void> toggleTask(TodoModel task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await DatabaseService().updateTodo(updatedTask);
    _loadTasksFromDb(); // Refresh tasks after toggling completion
  }

  Future<void> deleteTask(TodoModel task) async {
    await DatabaseService().deleteTodo(task.id!);
    _loadTasksFromDb(); // Refresh tasks after deletion
  }

  Future<void> updateTask(
      TodoModel task,
      String newTitle,
      String? newDescription,
      DateTime? newDueDate,
      TimeOfDay? newReminder,
      PriorityLevel newPriority) async {
    final updatedTask = task.copyWith(
      todoTitle: newTitle,
      description: newDescription,
      dueDate: newDueDate,
      reminder: newReminder,
      priority: newPriority,
    );
    await DatabaseService().updateTodo(updatedTask);
    _loadTasksFromDb(); // Refresh tasks after updating
  }

  Future<void> _loadTasksFromDb() async {
    _tasks = await DatabaseService().todos();
    notifyListeners();
  }
}
