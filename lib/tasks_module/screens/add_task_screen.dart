import 'package:flutter/material.dart';
// simple date formatting without extra packages
import '../models/task.dart';
import '../task_repository.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  Duration _duration = const Duration(hours: 1);
  String _priority = 'Medium';
  String _category = 'Academic';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deadline is required')));
      return;
    }
    final repo = TaskRepository.instance;
    final t = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameCtrl.text.trim(),
      category: _category,
      description: _descCtrl.text.trim(),
      deadline: _deadline!,
      durationMins: _duration.inMinutes,
      userPriority: _priority == 'Low'
          ? 1
          : _priority == 'Medium'
              ? 3
              : _priority == 'High'
                  ? 4
                  : 5,
      moodTag: _category == 'Academic' ? 'Focus' : 'Routine',
      location: '',
      status: 'Pending',
      tags: [_category],
    );
    repo.add(t);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Task name required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Short Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(_deadline == null ? 'Not set' : _deadline!.toLocal().toString().split(' ')[0]),
                trailing: TextButton(onPressed: _pickDeadline, child: const Text('Pick')),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Low', 'Medium', 'High', 'Critical'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _priority = v ?? _priority),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Academic', 'Coding', 'Placement', 'Personal', 'Project']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Estimated Duration'),
                subtitle: Text('${_duration.inHours}h ${_duration.inMinutes.remainder(60)}m'),
                trailing: IconButton(
                  onPressed: () async {
                    // quick adjust
                    final hours = await showDialog<int?>(
                      context: context,
                      builder: (c) => SimpleDialog(
                        title: const Text('Hours'),
                        children: List.generate(9, (i) => i + 1)
                            .map((h) => SimpleDialogOption(onPressed: () => Navigator.pop(c, h), child: Text('$h h')))
                            .toList(),
                      ),
                    );
                    if (hours != null) setState(() => _duration = Duration(hours: hours));
                  },
                  icon: const Icon(Icons.timer),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save Task'))),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
