import 'package:flutter/material.dart';
import 'package:nova_app/events_module/add_event.dart';
import 'package:nova_app/events_module/event_model.dart';
import 'package:nova_app/events_module/event_repository.dart';
import 'package:nova_app/events_module/event_viewmodel.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final day = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$day • $hour:$minute $suffix';
  }

  String _repeatDaysLabel(List<int> days) {
    if (days.isEmpty) return 'No specific weekdays selected';
    return EventViewModel.instance.formatRepeatDays(days).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: EventRepository.instance.events,
      builder: (context, _, __) {
        final current = EventRepository.instance.byId(event.id) ?? event;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete event?'),
                      content: Text('Delete "${current.title}" from your events list?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  EventViewModel.instance.remove(current.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            current.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (current.isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              current.repeatType.label,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(icon: Icons.label_outline, label: current.category),
                        _MetaChip(icon: Icons.flag_outlined, label: current.importance.label),
                        _MetaChip(icon: Icons.tune_rounded, label: current.flexibility.label),
                        _MetaChip(icon: Icons.bolt_outlined, label: current.energyRequirement.label),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Description',
                child: Text(current.description),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Time Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(icon: Icons.calendar_today_outlined, label: 'Start', value: _formatDateTime(current.startDate, current.startTime)),
                    if (current.endDate != null && current.endTime != null) ...[
                      const SizedBox(height: 10),
                      _DetailRow(icon: Icons.event_available_outlined, label: 'End', value: _formatDateTime(current.endDate!, current.endTime!)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Recurrence Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(icon: Icons.autorenew_rounded, label: 'Repeat Type', value: current.repeatType.label),
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.event_repeat_outlined, label: 'Repeat Days', value: _repeatDaysLabel(current.repeatDays)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Structure',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(icon: Icons.place_outlined, label: 'Location', value: current.location.trim().isNotEmpty == true ? current.location!.trim() : 'Not set'),
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.sell_outlined, label: 'Tags', value: current.tags.isEmpty ? 'None' : current.tags.map((tag) => '#$tag').join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddEventScreen(event: current)),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Event'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }
}