import 'package:flutter/foundation.dart';

@immutable
class Task {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final Duration estimatedDuration;
  final String priority; // Low, Medium, High, Critical
  final String category; // Academic, Coding, ...
  final String status; // Pending, In Progress, Completed

  const Task({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.estimatedDuration,
    required this.priority,
    required this.category,
    required this.status,
  });

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? deadline,
    Duration? estimatedDuration,
    String? priority,
    String? category,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'estimatedDuration': estimatedDuration.inMinutes,
        'priority': priority,
        'category': category,
        'status': status,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String,
        deadline: DateTime.parse(m['deadline'] as String),
        estimatedDuration: Duration(minutes: m['estimatedDuration'] as int),
        priority: m['priority'] as String,
        category: m['category'] as String,
        status: m['status'] as String,
      );

  @override
  String toString() => 'Task($id, $name)';
}
