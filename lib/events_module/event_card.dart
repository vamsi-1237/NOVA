import 'package:flutter/material.dart';
import 'package:nova_app/routes/routes.dart';

import 'event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  Color _importanceColor(BuildContext context) {
    switch (event.importance) {
      case EventImportance.low:
        return Colors.teal;
      case EventImportance.medium:
        return Colors.orange;
      case EventImportance.high:
        return Colors.redAccent;
    }
  }

  Color _accentColor(BuildContext context) {
    switch (event.categoryEnum) {
      case EventCategory.academic:
        return Colors.indigo;
      case EventCategory.health:
        return Colors.green;
      case EventCategory.fitness:
        return Colors.deepOrange;
      case EventCategory.work:
        return Colors.blueGrey;
      case EventCategory.productivity:
        return Colors.blue;
      case EventCategory.personal:
        return Colors.pink;
      case EventCategory.social:
        return Colors.amber.shade700;
      case EventCategory.finance:
        return Colors.teal.shade700;
      case EventCategory.other:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatDateTime() {
    final date = event.startDate;
    final time = event.startTime;
    final day = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$day • $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(context);
    final importanceColor = _importanceColor(context);

    return Material(
      color: Theme.of(context).cardColor,
      elevation: 0.8,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).pushNamed(Routes.eventDetail, arguments: event),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 84,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: importanceColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            event.importance.label,
                            style: TextStyle(color: importanceColor, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoChip(label: event.categoryLabel, icon: Icons.label_outline),
                        _InfoChip(label: _formatDateTime(), icon: Icons.schedule_outlined),
                        if (event.isRecurring)
                          _InfoChip(
                            label: event.repeatTypeLabel,
                            icon: Icons.autorenew_rounded,
                            emphasized: true,
                          ),
                        if (event.location.trim().isNotEmpty)
                          const _LocationIcon(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool emphasized;

  const _InfoChip({required this.label, required this.icon, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final color = emphasized ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(emphasized ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.place_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant);
  }
}