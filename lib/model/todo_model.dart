import 'dart:convert';

import 'package:flutter/material.dart';

enum PriorityLevel { low, medium, high }

class TodoModel {
  int? id;
  String todoTitle;
  String? description;
  bool completed;
  DateTime? dueDate;
  TimeOfDay? reminder;
  PriorityLevel priority;
  final DateTime creationDate;

  TodoModel({
    this.id,
    required this.todoTitle,
    this.description,
    this.completed = false,
    this.dueDate,
    this.reminder,
    this.priority = PriorityLevel.medium,
  }) : creationDate = DateTime.now();

  void toggleCompleted() {
    completed = !completed;
  }

  TodoModel copyWith({
    int? id,
    String? todoTitle,
    String? description,
    bool? completed,
    DateTime? dueDate,
    TimeOfDay? reminder,
    PriorityLevel? priority,
  }) {
    return TodoModel(
      id: id ?? this.id,
      todoTitle: todoTitle ?? this.todoTitle,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'todoTitle': todoTitle,
        'description': description,
        'completed': completed ? 1 : 0,
        'dueDate': dueDate?.toIso8601String(),
        'reminder': reminder != null
            ? jsonEncode({'hour': reminder!.hour, 'minute': reminder!.minute})
            : null,
        'priority': priority.index,
        'creationDate': creationDate.toIso8601String(),
      };

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'],
        todoTitle: json['todoTitle'],
        description: json['description'],
        completed: json['completed'] == 1,
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        reminder: json['reminder'] != null
            ? TimeOfDay(
                hour: jsonDecode(json['reminder'])['hour'],
                minute: jsonDecode(json['reminder'])['minute'],
              )
            : null,
        priority: PriorityLevel.values[json['priority']],
      );
}
