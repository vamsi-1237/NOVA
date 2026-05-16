import 'package:flutter/material.dart';
import '../models/task.dart';
import '../task_repository.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              repo.remove(task.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(children: [
            Chip(label: Text(task.priority)),
            const SizedBox(width: 8),
            Chip(label: Text(task.category)),
            const SizedBox(width: 8),
            if (task.status == 'Completed') const Icon(Icons.check_circle, color: Colors.green)
          ]),
          const SizedBox(height: 12),
          Text('Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}'),
          const SizedBox(height: 8),
          Text('Estimated: ${task.estimatedDuration.inHours}h ${task.estimatedDuration.inMinutes.remainder(60)}m'),
          const SizedBox(height: 12),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(task.description),
          const Spacer(),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  repo.toggleComplete(task.id);
                  Navigator.of(context).pop();
                },
                child: Text(task.status == 'Completed' ? 'Mark Pending' : 'Mark Complete'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ])
        ]),
      ),
    );
  }
}
