import 'package:flutter/material.dart';
import 'package:nova_app/routes/routes.dart';
import '../task_repository.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

const _categories = ['All', 'Academic', 'Coding', 'Placement', 'Personal', 'Project'];
const _priorities = ['All', 'Low', 'Medium', 'High', 'Critical'];

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final repo = TaskRepository.instance;
  String categoryFilter = 'All';
  String priorityFilter = 'All';
  bool sortByDeadlineAsc = true;

  @override
  void initState() {
    super.initState();
    repo.seedSample();
  }

  List filteredTasks(List tasks) {
    var list = tasks.cast();
    if (categoryFilter != 'All') {
      list = list.where((t) => t.category == categoryFilter).toList();
    }
    if (priorityFilter != 'All') {
      list = list.where((t) => t.priority == priorityFilter).toList();
    }
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    if (!sortByDeadlineAsc) list = list.reversed.toList();
    // Completed tasks move lower
    list.sort((a, b) {
      if (a.status == b.status) return 0;
      if (a.status == 'Completed') return 1;
      return -1;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => setState(() => sortByDeadlineAsc = !sortByDeadlineAsc),
            tooltip: 'Toggle sort by deadline',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Filters with headings for clarity
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject / Category column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: _categories.map((c) {
                          final selected = categoryFilter == c;
                          return ChoiceChip(
                            label: Text(c),
                            selected: selected,
                            onSelected: (_) => setState(() => categoryFilter = c),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Priority column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: _priorities.map((p) {
                          final selected = priorityFilter == p;
                          return ChoiceChip(
                            label: Text(p),
                            selected: selected,
                            onSelected: (_) => setState(() => priorityFilter = p),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List>(
                valueListenable: repo.tasks,
                builder: (context, list, _) {
                  final items = filteredTasks(list);
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt, size: 72, color: Theme.of(context).hintColor),
                          const SizedBox(height: 8),
                          const Text('No tasks yet', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          const Text('Start organizing your work'),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => TaskCard(task: items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.addTask),
        child: const Icon(Icons.add),
      ),
    );
  }
}
