import 'package:flutter/material.dart';
import 'package:nova_app/routes/routes.dart';

import 'event_card.dart';
import 'event_model.dart';
import 'event_repository.dart';
import 'event_viewmodel.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventViewModel vm = EventViewModel.instance;

  @override
  void initState() {
    super.initState();
    vm.seedSample();
  }

  List<_ListItem> _buildItems(List<Event> ongoing, List<Event> upcoming) {
    final items = <_ListItem>[
      if (ongoing.isNotEmpty) ...[
        _ListItem.header('Ongoing Routines', ongoing.length),
        ...ongoing.map(_ListItem.event),
      ],
      if (upcoming.isNotEmpty) ...[
        _ListItem.header('Upcoming Events', upcoming.length),
        ...upcoming.map(_ListItem.event),
      ],
    ];

    if (items.isEmpty) {
      items.add(_ListItem.empty());
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.primary.withOpacity(0.04), Colors.transparent],
          ),
        ),
        child: ValueListenableBuilder<List<Event>>(
          valueListenable: EventRepository.instance.events,
          builder: (context, _, __) {
            final ongoing = vm.ongoingRoutines;
            final upcoming = vm.upcomingEvents;
            final items = _buildItems(ongoing, upcoming);

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.type == _ListItemType.empty) {
                  return _EmptyState(onAdd: () => Navigator.of(context).pushNamed(Routes.addEvent));
                }
                if (item.type == _ListItemType.header) {
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 16, bottom: 12),
                    child: Row(
                      children: [
                        Text(
                          item.title!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${item.count}',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(event: item.event!),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(Routes.addEvent),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }
}

enum _ListItemType { header, event, empty }

class _ListItem {
  final _ListItemType type;
  final String? title;
  final int? count;
  final Event? event;

  const _ListItem._(this.type, {this.title, this.count, this.event});

  factory _ListItem.header(String title, int count) => _ListItem._(_ListItemType.header, title: title, count: count);

  factory _ListItem.event(Event event) => _ListItem._(_ListItemType.event, event: event);

  factory _ListItem.empty() => const _ListItem._(_ListItemType.empty);
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note_outlined, size: 72, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            const Text('No events yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Add routines, milestones, and important moments to help NOVA plan around them.'),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Event')),
          ],
        ),
      ),
    );
  }
}