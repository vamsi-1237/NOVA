import 'dart:math';

import 'package:flutter/material.dart';
import 'models/task.dart';

class TaskRepository {
  TaskRepository._internal();
  static final TaskRepository instance = TaskRepository._internal();

  final ValueNotifier<List<Task>> tasks = ValueNotifier<List<Task>>([]);

  // seed with a couple of sample tasks
  void seedSample() {
    if (tasks.value.isNotEmpty) return;
    tasks.value = [
      Task(
        id: _id(),
        name: 'Finish assignment',
        description: 'Complete the assignment on state management.',
        deadline: DateTime.now().add(const Duration(days: 2)),
        estimatedDuration: const Duration(hours: 2),
        priority: 'High',
        category: 'Academic',
        status: 'Pending',
      ),
      Task(
        id: _id(),
        name: 'Solve DSA problems',
        description: 'Solve 5 problems on arrays and trees.',
        deadline: DateTime.now().add(const Duration(days: 5)),
        estimatedDuration: const Duration(hours: 4),
        priority: 'Medium',
        category: 'Coding',
        status: 'In Progress',
      ),
    ];
  }

  String _id() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();

  void add(Task t) {
    tasks.value = [...tasks.value, t];
  }

  void update(String id, Task t) {
    tasks.value = tasks.value.map((e) => e.id == id ? t : e).toList();
  }

  void remove(String id) {
    tasks.value = tasks.value.where((e) => e.id != id).toList();
  }

  Task? byId(String id) => tasks.value.firstWhere((e) => e.id == id);

  void toggleComplete(String id) {
    final t = byId(id);
    if (t == null) return;
    final updated = t.copyWith(status: t.status == 'Completed' ? 'Pending' : 'Completed');
    update(id, updated);
  }
}
