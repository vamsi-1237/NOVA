import 'package:flutter/material.dart';

class ScheduleResultsPage extends StatelessWidget {
  final Map<String, dynamic> results;

  const ScheduleResultsPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = results.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Items')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final items = results[day] as List<dynamic>;
            final total = items.fold<int>(0, (p, e) => p + (e['durationMins'] as int));
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: Text('$day — ${total} mins'),
                children: items.map<Widget>((it) {
                  final start = DateTime.tryParse(it['start'] as String? ?? '');
                  final end = DateTime.tryParse(it['end'] as String? ?? '');
                  final timeRange = start != null && end != null
                      ? '${start.toLocal().hour.toString().padLeft(2, '0')}:${start.toLocal().minute.toString().padLeft(2, '0')} - ${end.toLocal().hour.toString().padLeft(2, '0')}:${end.toLocal().minute.toString().padLeft(2, '0')}'
                      : '';
                  return ListTile(
                    title: Text(it['title'] as String? ?? ''),
                    subtitle: Text('${it['durationMins']} mins • ${it['category']} ${timeRange.isEmpty ? '' : '• $timeRange'}\n${it['location'] ?? ''}'),
                    isThreeLine: true,
                    trailing: Icon((it['isEvent'] as bool) ? Icons.event : Icons.task),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
