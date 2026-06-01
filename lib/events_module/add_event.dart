import 'package:flutter/material.dart';
import 'package:nova_app/events_module/event_model.dart';
import 'package:nova_app/events_module/event_viewmodel.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  late EventCategory _category;
  late EventRecurrenceType _repeatType;
  late EventImportance _importance;
  late EventFlexibility _flexibility;
  late EventEnergyRequirement _energyRequirement;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<int> _repeatDays = <int>{};

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController.text = event?.title ?? '';
    _descriptionController.text = event?.description ?? '';
    _locationController.text = event?.location ?? '';
    _tagsController.text = event?.tags.map((tag) => '#$tag').join(', ') ?? '';
    _category = event?.categoryEnum ?? EventCategory.academic;
    _repeatType = event?.repeatType ?? EventRecurrenceType.none;
    _importance = event?.importance ?? EventImportance.medium;
    _flexibility = event?.flexibility ?? EventFlexibility.slightlyFlexible;
    _energyRequirement = event?.energyRequirement ?? EventEnergyRequirement.mediumEnergy;
    _startDate = event?.startDate;
    _endDate = event?.endDate;
    _startTime = event?.startTime;
    _endTime = event?.endTime;
    _repeatDays.addAll(event?.repeatDays ?? const []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate ?? DateTime.now() : _endDate ?? _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime ?? TimeOfDay.now() : _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Not set';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.startsWith('#') ? tag.substring(1) : tag)
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start date and start time are required')));
      return;
    }

    if ((_repeatType == EventRecurrenceType.weekly || _repeatType == EventRecurrenceType.custom) && _repeatDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one weekday for this recurrence')));
      return;
    }

    final startAt = _combine(_startDate!, _startTime!);
    DateTime? endAt;
    if (_endDate != null && _endTime != null) {
      endAt = _combine(_endDate!, _endTime!);
      if (endAt.isBefore(startAt)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date/time must be after the start')));
        return;
      }
    } else if (_endDate != null || _endTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set both end date and end time, or leave both empty')));
      return;
    }

    final repo = EventViewModel.instance;
    final event = Event(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category.label,
      deadline: startAt,
      durationMins: endAt == null ? 60 : endAt.difference(startAt).inMinutes,
      bufferAfterMins: _flexibility == EventFlexibility.fixed ? 0 : 15,
      earliestStart: startAt,
      userPriority: _importance == EventImportance.low ? 2 : _importance == EventImportance.medium ? 3 : 5,
      impactScore: _importance == EventImportance.low ? 0.45 : _importance == EventImportance.medium ? 0.7 : 0.9,
      isFixed: _flexibility == EventFlexibility.fixed,
      recurrenceMask: _repeatType == EventRecurrenceType.none ? 0 : (_repeatType == EventRecurrenceType.daily ? 127 : _repeatDays.fold<int>(0, (mask, day) => mask | (1 << (day - 1)))),
      isRecurring: _repeatType != EventRecurrenceType.none,
      energyRequired: _energyRequirement == EventEnergyRequirement.lowEnergy ? 1 : _energyRequirement == EventEnergyRequirement.mediumEnergy ? 3 : 5,
      moodTag: _tagsController.text.trim().isEmpty ? _category.label : _tagsController.text.trim(),
      location: _locationController.text.trim(),
      status: 'Scheduled',
      tags: _parseTags(),
    );

    if (_isEditing) {
      repo.upsert(event);
    } else {
      repo.add(event);
    }

    Navigator.of(context).pop(true);
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }

  Widget _weekdayChip(int weekday, String label) {
    final selected = _repeatDays.contains(weekday);
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (value) {
        setState(() {
          if (value) {
            _repeatDays.add(weekday);
          } else {
            _repeatDays.remove(weekday);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Event' : 'Add Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Basic Information', subtitle: 'Capture the structure NOVA can schedule around later.'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Event title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description / Notes', alignLabelWithHint: true, border: OutlineInputBorder()),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: EventCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(category.label))).toList(),
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Time Information'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_formatDate(_startDate)),
                    trailing: OutlinedButton(onPressed: () => _pickDate(isStart: true), child: const Text('Pick')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_formatDate(_endDate)),
                    trailing: TextButton(
                      onPressed: () async {
                        await _pickDate(isStart: false);
                      },
                      child: const Text('Optional'),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_formatTime(_startTime)),
                    trailing: OutlinedButton(onPressed: () => _pickTime(isStart: true), child: const Text('Pick')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_formatTime(_endTime)),
                    trailing: TextButton(
                      onPressed: () async {
                        await _pickTime(isStart: false);
                      },
                      child: const Text('Optional'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Recurrence', subtitle: 'Store repeat behavior structurally, not as plain text.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventRecurrenceType.values
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type.label),
                      selected: _repeatType == type,
                      onSelected: (_) => setState(() => _repeatType = type),
                    ),
                  )
                  .toList(),
            ),
            if (_repeatType == EventRecurrenceType.weekly || _repeatType == EventRecurrenceType.custom) ...[
              const SizedBox(height: 12),
              Text('Repeat Days', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _weekdayChip(DateTime.monday, 'Mon'),
                  _weekdayChip(DateTime.tuesday, 'Tue'),
                  _weekdayChip(DateTime.wednesday, 'Wed'),
                  _weekdayChip(DateTime.thursday, 'Thu'),
                  _weekdayChip(DateTime.friday, 'Fri'),
                  _weekdayChip(DateTime.saturday, 'Sat'),
                  _weekdayChip(DateTime.sunday, 'Sun'),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _sectionTitle('Scheduling Signals', subtitle: 'These fields help future AI protect high-value events.'),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventImportance>(
              value: _importance,
              decoration: const InputDecoration(labelText: 'Importance Level', border: OutlineInputBorder()),
              items: EventImportance.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(),
              onChanged: (value) => setState(() => _importance = value ?? _importance),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventFlexibility>(
              value: _flexibility,
              decoration: const InputDecoration(labelText: 'Flexibility Level', border: OutlineInputBorder()),
              items: EventFlexibility.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(),
              onChanged: (value) => setState(() => _flexibility = value ?? _flexibility),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventEnergyRequirement>(
              value: _energyRequirement,
              decoration: const InputDecoration(labelText: 'Energy Requirement', border: OutlineInputBorder()),
              items: EventEnergyRequirement.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(),
              onChanged: (value) => setState(() => _energyRequirement = value ?? _energyRequirement),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Optional Tags',
                hintText: '#health, #coding, #semester',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Event' : 'Save Event'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}