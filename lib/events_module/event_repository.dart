import 'dart:math';

import 'package:flutter/material.dart';

import 'event_model.dart';

class EventRepository {
  EventRepository._internal();

  static final EventRepository instance = EventRepository._internal();

  final ValueNotifier<List<Event>> events = ValueNotifier<List<Event>>([]);
  final Random _random = Random();

  void seedSample() {
    if (events.value.isNotEmpty) return;

    final now = DateTime.now();
    events.value = [
      Event(
        id: _id(),
        title: 'Gym',
        category: 'Fitness',
        description: 'Evening strength and cardio session.',
        location: 'Campus gym',
        deadline: DateTime(now.year, now.month, now.day, 18, 0),
        durationMins: 75,
        bufferAfterMins: 15,
        userPriority: 3,
        impactScore: 0.72,
        isFixed: false,
        recurrenceMask: 127,
        isRecurring: true,
        energyRequired: 5,
        moodTag: 'Routine',
        status: 'Scheduled',
        tags: const ['health', 'fitness'],
      ),
      Event(
        id: _id(),
        title: 'DSA Practice',
        category: 'Coding',
        description: 'Solve arrays and trees problems for interview prep.',
        location: 'Study desk',
        deadline: DateTime(now.year, now.month, now.day, 20, 0),
        durationMins: 120,
        bufferAfterMins: 30,
        userPriority: 4,
        impactScore: 0.85,
        isFixed: false,
        recurrenceMask: 1 | 4 | 16,
        isRecurring: true,
        energyRequired: 5,
        moodTag: 'Focus',
        status: 'Scheduled',
        tags: const ['coding', 'career'],
      ),
      Event(
        id: _id(),
        title: 'Meditation',
        category: 'Health',
        description: 'Short reset session before starting the day.',
        location: 'Balcony',
        deadline: DateTime(now.year, now.month, now.day, 6, 30),
        durationMins: 20,
        bufferAfterMins: 10,
        userPriority: 2,
        impactScore: 0.5,
        isFixed: false,
        recurrenceMask: 127,
        isRecurring: true,
        energyRequired: 1,
        moodTag: 'Chill',
        status: 'Scheduled',
        tags: const ['wellbeing'],
      ),
      Event(
        id: _id(),
        title: 'Mid-semester Exams',
        category: 'Academic',
        description: 'Prepare and appear for semester exams.',
        location: 'College campus',
        deadline: now.add(const Duration(days: 10, hours: 9)),
        durationMins: 8 * 60,
        bufferAfterMins: 30,
        userPriority: 5,
        impactScore: 0.95,
        isFixed: true,
        recurrenceMask: 0,
        isRecurring: false,
        energyRequired: 5,
        moodTag: 'Focus',
        earliestStart: now.add(const Duration(days: 10)),
        status: 'Scheduled',
        tags: const ['semester', 'academic'],
      ),
      Event(
        id: _id(),
        title: 'Product Design Interview',
        category: 'Work',
        description: 'Final interview round with the design team.',
        location: 'Hybrid',
        deadline: now.add(const Duration(days: 4, hours: 11, minutes: 30)),
        durationMins: 90,
        bufferAfterMins: 30,
        userPriority: 5,
        impactScore: 0.92,
        isFixed: true,
        recurrenceMask: 0,
        isRecurring: false,
        energyRequired: 5,
        moodTag: 'Focus',
        status: 'Scheduled',
        tags: const ['career', 'placement'],
      ),
      Event(
        id: _id(),
        title: 'AI Seminar',
        category: 'Social',
        description: 'Guest lecture on AI in education workflows.',
        location: 'Seminar hall',
        deadline: now.add(const Duration(days: 6, hours: 15)),
        durationMins: 60,
        bufferAfterMins: 15,
        userPriority: 3,
        impactScore: 0.65,
        isFixed: false,
        recurrenceMask: 0,
        isRecurring: false,
        energyRequired: 3,
        moodTag: 'Creative',
        status: 'Scheduled',
        tags: const ['seminar', 'learning'],
      ),
    ];
  }

  String _id() => DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(9999).toString();

  void add(Event event) {
    events.value = [...events.value, event];
  }

  void update(String id, Event event) {
    events.value = events.value.map((existing) => existing.id == id ? event : existing).toList();
  }

  void upsert(Event event) {
    final exists = byId(event.id) != null;
    if (exists) {
      update(event.id, event);
    } else {
      add(event);
    }
  }

  void remove(String id) {
    events.value = events.value.where((event) => event.id != id).toList();
  }

  Event? byId(String id) {
    for (final event in events.value) {
      if (event.id == id) return event;
    }
    return null;
  }
}