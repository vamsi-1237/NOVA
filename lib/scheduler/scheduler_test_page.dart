import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nova_app/tasks_module/models/task.dart';
import 'package:nova_app/tasks_module/task_repository.dart';
import 'package:nova_app/events_module/event_model.dart';
import 'package:nova_app/events_module/event_repository.dart';
import 'package:nova_app/models/schedulable_item.dart';
import 'package:nova_app/routes/routes.dart';

class SchedulerTestPage extends StatefulWidget {
  const SchedulerTestPage({Key? key}) : super(key: key);

  @override
  State<SchedulerTestPage> createState() => _SchedulerTestPageState();
}

class _SchedulerTestPageState extends State<SchedulerTestPage> {
  List<Task> _tasks = [];
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInput();
  }

  Future<void> _loadInput() async {
    try {
      final data = await rootBundle.loadString('data/input.json');
      final m = jsonDecode(data) as Map<String, dynamic>;
      final tasks = (m['tasks'] as List<dynamic>? ?? [])
          .map((e) => Task.fromMap(e as Map<String, dynamic>))
          .toList();
      final events = (m['events'] as List<dynamic>? ?? [])
          .map((e) => Event.fromMap(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _tasks = tasks;
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load input: $e')));
    }
  }

  Future<void> _insertIntoRepos() async {
    final tRepo = TaskRepository.instance;
    final eRepo = EventRepository.instance;
    for (final t in _tasks) {
      tRepo.add(t);
    }
    for (final e in _events) {
      eRepo.add(e);
    }
  }

  void _onConfirm() async {
    await _insertIntoRepos();
    // Combine items
    final all = <SchedulableItem>[];
    all.addAll(TaskRepository.instance.tasks.value);
    all.addAll(EventRepository.instance.events.value);

    // Filter out completed items
    final pending = all
        .where((i) => i.status.toLowerCase() != 'completed')
        .toList();

    // Precompute helper scores
    DateTime todayDate = DateTime.now();
    String dayKey(DateTime d) => d.toIso8601String().split('T').first;

    double deadlineScoreFor(SchedulableItem i) {
      final dDate = DateTime(i.deadline.year, i.deadline.month, i.deadline.day);
      final daysUntil = dDate
          .difference(DateTime(todayDate.year, todayDate.month, todayDate.day))
          .inDays;
      final days = daysUntil < 0 ? 0 : daysUntil;
      final urgency = 1.0 / (1.0 + days);
      final energyFactor = (i.energyRequired.clamp(1, 5)) / 5.0;
      return urgency * energyFactor;
    }

    // Sort by combined: deadline proximity*energy + impactScore, then scheduleScore
    double combinedPriority(SchedulableItem i) {
      final ds = deadlineScoreFor(i);
      final impact = (i.impactScore).clamp(0.0, 1.0);
      return (ds * 0.6) + (impact * 0.4);
    }

    pending.sort((a, b) {
      final cp = combinedPriority(b).compareTo(combinedPriority(a));
      if (cp != 0) return cp;
      final sc = b.scheduleScore.compareTo(a.scheduleScore);
      if (sc != 0) return sc;
      return compareSchedulableItems(a, b);
    });

    // Scheduling constraints
    const int dailyLimit = 300; // minutes per day
    const int highEnergyThreshold = 4; // energyRequired >=4 considered high
    const int maxHighEnergyPerDay = 2;
    const int workWindowStartHour = 16; // 4pm
    const int workWindowEndHour = 24; // midnight

    final Map<String, List<Map<String, dynamic>>> assigned = {};
    final Map<String, int> used = {};
    final Map<String, int> highEnergyCount = {};

    // Helper to try place item on a day with time assignment
    DateTime makeStart(DateTime day, int offsetMins) {
      return DateTime(
        day.year,
        day.month,
        day.day,
        workWindowStartHour,
      ).add(Duration(minutes: offsetMins));
    }

    // For each day we'll keep current offset minutes from start hour
    final Map<String, int> dayOffset = {};

    // Pre-fill mandatory routines per day (recurring events)
    final List<SchedulableItem> nonRecurring = [];
    for (final item in pending) {
      if (item is Event && item.isRecurring) {
        for (var day = 0; day <= 14; day++) {
          final d = DateTime(
            todayDate.year,
            todayDate.month,
            todayDate.day,
          ).add(Duration(days: day));
          final wd = d.weekday;
          if (item.recurrenceDays.contains(wd)) {
            final key = dayKey(d);
            final usedMins = used[key] ?? 0;
            if (item.isFixed) {
              // schedule at the event's configured time-of-day
              final start = DateTime(
                d.year,
                d.month,
                d.day,
                item.deadline.hour,
                item.deadline.minute,
              );
              final end = start.add(Duration(minutes: item.durationMins));
              if (start.hour >= workWindowStartHour &&
                  end.hour < workWindowEndHour &&
                  usedMins + item.durationMins <= dailyLimit) {
                assigned.putIfAbsent(key, () => []).add({
                  'item': item,
                  'start': start.toIso8601String(),
                  'end': end.toIso8601String(),
                });
                used[key] = usedMins + item.durationMins;
                final he = highEnergyCount[key] ?? 0;
                if (item.energyRequired >= highEnergyThreshold)
                  highEnergyCount[key] = he + 1;
              }
            } else {
              if (usedMins + item.durationMins <= dailyLimit) {
                assigned.putIfAbsent(key, () => []).add({
                  'item': item,
                  'start': null,
                  'end': null,
                });
                used[key] = usedMins + item.durationMins;
                final he = highEnergyCount[key] ?? 0;
                if (item.energyRequired >= highEnergyThreshold)
                  highEnergyCount[key] = he + 1;
              }
            }
          }
        }
      } else {
        nonRecurring.add(item);
      }
    }

    // Now place non-recurring items (tasks and single events) respecting deadline and constraints
    for (final item in nonRecurring) {
      final lastDay = DateTime(
        item.deadline.year,
        item.deadline.month,
        item.deadline.day,
      );
      bool placed = false;

      // try days from today up to lastDay
      for (
        var d = DateTime(todayDate.year, todayDate.month, todayDate.day);
        !d.isAfter(lastDay);
        d = d.add(const Duration(days: 1))
      ) {
        final key = dayKey(d);
        final usedMins = used[key] ?? 0;
        final heCount = highEnergyCount[key] ?? 0;

        // energy constraint
        if (item.energyRequired >= highEnergyThreshold &&
            heCount >= maxHighEnergyPerDay)
          continue;

        // If item is fixed, only schedule on its exact deadline day/time
        if (item.isFixed) {
          if (d.year != item.deadline.year ||
              d.month != item.deadline.month ||
              d.day != item.deadline.day)
            continue;
          final start = DateTime(
            d.year,
            d.month,
            d.day,
            item.deadline.hour,
            item.deadline.minute,
          );
          final end = start.add(Duration(minutes: item.durationMins));
          // respect earliestStart
          if (item.earliestStart != null) {
            if (start.isBefore(item.earliestStart!)) continue;
          }
          if (start.hour >= workWindowStartHour &&
              end.hour < workWindowEndHour &&
              usedMins + item.durationMins <= dailyLimit) {
            assigned.putIfAbsent(key, () => []).add({
              'item': item,
              'start': start.toIso8601String(),
              'end': end.toIso8601String(),
            });
            used[key] = usedMins + item.durationMins;
            if (item.energyRequired >= highEnergyThreshold)
              highEnergyCount[key] = heCount + 1;
            placed = true;
            break;
          }
        } else {
          if (usedMins + item.durationMins <= dailyLimit) {
            assigned.putIfAbsent(key, () => []).add({
              'item': item,
              'start': null,
              'end': null,
            });
            used[key] = usedMins + item.durationMins;
            if (item.energyRequired >= highEnergyThreshold)
              highEnergyCount[key] = heCount + 1;
            placed = true;
            break;
          } else {
            // try to free space by removing lowest-priority recurring routine if this item has higher deadline score
            final dayList = assigned[key] ?? [];
            if (dayList.isNotEmpty) {
              // find the lowest deadlineScore routine in that day
              int idx = -1;
              double lowestScore = double.infinity;
              for (var i = 0; i < dayList.length; i++) {
                final entry = dayList[i];
                final it = entry['item'] as SchedulableItem;
                if (it is Event && it.isRecurring) {
                  final score = deadlineScoreFor(it);
                  if (score < lowestScore) {
                    lowestScore = score;
                    idx = i;
                  }
                }
              }
              if (idx != -1 && deadlineScoreFor(item) > lowestScore) {
                // remove that routine and place current item
                final removed =
                    dayList.removeAt(idx)['item'] as SchedulableItem;
                used[key] = (used[key] ?? 0) - removed.durationMins;
                if (removed.energyRequired >= highEnergyThreshold) {
                  highEnergyCount[key] = (highEnergyCount[key] ?? 1) - 1;
                }
                // now place current
                assigned.putIfAbsent(key, () => []).add({
                  'item': item,
                  'start': null,
                  'end': null,
                });
                used[key] = (used[key] ?? 0) + item.durationMins;
                if (item.energyRequired >= highEnergyThreshold)
                  highEnergyCount[key] = (highEnergyCount[key] ?? 0) + 1;
                placed = true;
                break;
              }
            }
          }
        }
        // if not placed by deadline, try previous days up to 3 days back
        if (!placed) {
          for (var back = 1; back <= 3 && !placed; back++) {
            final d = todayDate.subtract(Duration(days: back));
            final key = dayKey(d);
            final usedMins = used[key] ?? 0;
            final heCount = highEnergyCount[key] ?? 0;
            if (item.energyRequired >= highEnergyThreshold &&
                heCount >= maxHighEnergyPerDay)
              continue;
            if (usedMins + item.durationMins <= dailyLimit) {
              assigned.putIfAbsent(key, () => []).add({
                'item': item,
                'start': null,
                'end': null,
              });
              used[key] = usedMins + item.durationMins;
              if (item.energyRequired >= highEnergyThreshold)
                highEnergyCount[key] = heCount + 1;
              placed = true;
              break;
            }
          }
        }
        // leave unassigned if still not placed
      }

      // (scheduling placement for this item complete) continue to next item
    }

    // After all non-recurring items have been placed, compute day-level placements
    // and navigate to the results page once.
    final result = <String, dynamic>{};
    assigned.forEach((day, list) {
      // group by location to minimize alternations while preserving high-score ordering
      list.sort((a, b) {
        final ia = a['item'] as SchedulableItem;
        final ib = b['item'] as SchedulableItem;
        final da = deadlineScoreFor(ia);
        final db = deadlineScoreFor(ib);
        if (da != db) return db.compareTo(da);
        return ib.scheduleScore.compareTo(ia.scheduleScore);
      });

      // attempt to cluster same-location items consecutively
      final clustered = <Map<String, dynamic>>[];
      while (list.isNotEmpty) {
        final first = list.removeAt(0);
        clustered.add(first);
        final loc = (first['item'] as SchedulableItem).location;
        // pull following items with same location
        for (var i = list.length - 1; i >= 0; i--) {
          if ((list[i]['item'] as SchedulableItem).location == loc) {
            clustered.add(list.removeAt(i));
          }
        }
      }

      int offset = dayOffset[day] ?? 0;
      final placedList = <Map<String, dynamic>>[];
      for (final entry in clustered) {
        final item = entry['item'] as SchedulableItem;
        // If this entry already has a preassigned start (fixed event), preserve it
        final preStartStr = entry['start'] as String?;
        if (preStartStr != null) {
          final preStart = DateTime.parse(preStartStr);
          final preEnd = DateTime.parse(entry['end'] as String);
          // respect window
          if (preStart.hour < workWindowStartHour ||
              preEnd.hour >= workWindowEndHour) {
            continue;
          }
          placedList.add({
            'id': item.id,
            'title': item.title,
            'start': preStart.toIso8601String(),
            'end': preEnd.toIso8601String(),
            'durationMins': item.durationMins,
            'isEvent': item.isEvent,
            'deadline': item.deadline.toIso8601String(),
            'category': item.category,
            'location': item.location,
          });
          offset = (preEnd.hour - workWindowStartHour) * 60 + preEnd.minute;
          continue;
        }
        final start = makeStart(DateTime.parse('${day}T00:00:00'), offset);
        final end = start.add(Duration(minutes: item.durationMins));
        // ensure earliestStart is respected
        if (item.earliestStart != null) {
          final es = item.earliestStart!;
          if (es.year == start.year &&
              es.month == start.month &&
              es.day == start.day) {
            if (start.isBefore(es)) {
              final newStart = DateTime(
                start.year,
                start.month,
                start.day,
                es.hour,
                es.minute,
              );
              final newEnd = newStart.add(
                Duration(minutes: item.durationMins),
              );
              if (newEnd.hour >= workWindowEndHour) {
                // cannot place
                continue;
              }
              placedList.add({
                'id': item.id,
                'title': item.title,
                'start': newStart.toIso8601String(),
                'end': newEnd.toIso8601String(),
                'durationMins': item.durationMins,
                'isEvent': item.isEvent,
                'deadline': item.deadline.toIso8601String(),
                'category': item.category,
                'location': item.location,
              });
              offset = (newEnd.hour - workWindowStartHour) * 60 + newEnd.minute;
              continue;
            }
          }
        }
        // enforce end before window end
        if (end.hour >= workWindowEndHour) {
          // cannot place fully in this day; skip (we could mark unscheduled)
          continue;
        }
        placedList.add({
          'id': item.id,
          'title': item.title,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
          'durationMins': item.durationMins,
          'isEvent': item.isEvent,
          'deadline': item.deadline.toIso8601String(),
          'category': item.category,
          'location': item.location,
        });
        offset += item.durationMins + item.bufferAfterMins;
      }
      dayOffset[day] = offset;
      result[day] = placedList;
    });

    // Show loading then navigate
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    // minimal delay to simulate processing
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop(); // dismiss dialog

    Navigator.of(
      context,
    ).pushNamed(Routes.scheduleResults, arguments: result);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scheduler Test')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Preview items to insert',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          const Text(
                            'Tasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ..._tasks.map(
                            (t) => ListTile(
                              title: Text(t.title),
                              subtitle: Text(
                                '${t.durationMins} mins — ${t.deadline.toLocal()}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Events',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ..._events.map(
                            (e) => ListTile(
                              title: Text(e.title),
                              subtitle: Text(
                                '${e.durationMins} mins — ${e.deadline.toLocal()}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onConfirm,
                      child: const Text('Confirm and Run Scheduler'),
                    ),
                  ],
                ),
              ),
      );
    }
  }
