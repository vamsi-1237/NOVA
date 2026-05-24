import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/task_detail_screen.dart';
import 'package:nova_app/routes/routes.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({Key? key, required this.task}) : super(key: key);

  Color _priorityColor(String p, BuildContext context) {
    switch (p) {
      case 'Low':
        return Colors.green.shade300;
      case 'Medium':
        return Colors.orange.shade300;
      case 'High':
        return Colors.deepOrange.shade300;
      case 'Critical':
        return Colors.red.shade300;
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimmed = task.status == 'Completed';
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pushNamed(Routes.taskDetail, arguments: task),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 8,
              height: 48,
              decoration: BoxDecoration(
                color: _priorityColor(task.priority, context),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: dimmed ? Colors.grey : null)),
                const SizedBox(height: 6),
                Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: dimmed ? Colors.grey : null)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.calendar_today, size: 14, color: Theme.of(context).hintColor),
                  const SizedBox(width: 6),
                  Text(task.deadline.toLocal().toString().split(' ')[0], style: TextStyle(color: dimmed ? Colors.grey : null)),
                  const SizedBox(width: 12),
                  Chip(label: Text(task.priority, style: TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  Chip(label: Text(task.category, style: TextStyle(fontSize: 12))),
                ])
              ]),
            ),
            if (task.status == 'Completed') Icon(Icons.check, color: Colors.green.shade400),
          ]),
        ),
      ),
    );
  }
}
