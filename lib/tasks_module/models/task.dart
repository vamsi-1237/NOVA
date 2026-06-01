import 'package:flutter/foundation.dart';

import '../../models/schedulable_item.dart';

@immutable
class Task extends SchedulableItem {
  Task({
    required super.id,
    required super.title,
    super.isEvent = false,
    required super.category,
    required super.deadline,
    required super.durationMins,
    super.bufferAfterMins = 0,
    super.earliestStart,
    required super.userPriority,
    super.impactScore,
    super.isFixed = false,
    super.recurrenceMask = 0,
    super.isRecurring = false,
    super.energyRequired = 3,
    super.moodTag = '',
    required super.location,
    super.description = '',
    super.status = 'Pending',
    super.tags = const [],
  });

  @override
  String get name => title;

  @override
  Duration get estimatedDuration => Duration(minutes: durationMins);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    int? durationMins,
    int? bufferAfterMins,
    DateTime? earliestStart,
    int? userPriority,
    double? impactScore,
    bool? isFixed,
    int? recurrenceMask,
    bool? isRecurring,
    int? energyRequired,
    String? moodTag,
    String? location,
    String? category,
    String? status,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      durationMins: durationMins ?? this.durationMins,
      bufferAfterMins: bufferAfterMins ?? this.bufferAfterMins,
      earliestStart: earliestStart ?? this.earliestStart,
      userPriority: userPriority ?? this.userPriority,
      impactScore: impactScore ?? this.impactScore,
      isFixed: isFixed ?? this.isFixed,
      recurrenceMask: recurrenceMask ?? this.recurrenceMask,
      isRecurring: isRecurring ?? this.isRecurring,
      energyRequired: energyRequired ?? this.energyRequired,
      moodTag: moodTag ?? this.moodTag,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.statusText,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isEvent': isEvent,
        'category': category,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'durationMins': durationMins,
        'bufferAfterMins': bufferAfterMins,
        'earliestStart': earliestStart?.toIso8601String(),
        'userPriority': userPriority,
        'impactScore': impactScore,
        'isFixed': isFixed,
        'recurrenceMask': recurrenceMask,
        'isRecurring': isRecurring,
        'energyRequired': energyRequired,
        'moodTag': moodTag,
        'location': location,
        'status': status,
        'tags': tags,
      };

  factory Task.fromMap(Map<String, dynamic> m) {
    final title = (m['title'] as String?) ?? (m['name'] as String? ?? '');
    final durationMins = (m['durationMins'] as int?) ?? (m['estimatedDuration'] as int?) ?? 0;
    final userPriority = (m['userPriority'] as int?) ?? _legacyPriorityToLevel(m['priority'] as String?);
    final recurrenceMask = (m['recurrenceMask'] as int?) ?? _maskFromDays((m['repeatDays'] as List<dynamic>? ?? const []).map((day) => day as int).toList());
    return Task(
      id: m['id'] as String,
      title: title,
      description: m['description'] as String? ?? '',
      deadline: DateTime.parse(m['deadline'] as String),
      durationMins: durationMins,
      bufferAfterMins: m['bufferAfterMins'] as int? ?? 0,
      earliestStart: m['earliestStart'] == null ? null : DateTime.parse(m['earliestStart'] as String),
      userPriority: userPriority,
      impactScore: (m['impactScore'] as num?)?.toDouble(),
      isFixed: m['isFixed'] as bool? ?? false,
      recurrenceMask: recurrenceMask,
      isRecurring: m['isRecurring'] as bool? ?? false,
      energyRequired: m['energyRequired'] as int? ?? 3,
      moodTag: m['moodTag'] as String? ?? '',
      location: m['location'] as String? ?? '',
      category: m['category'] as String? ?? 'General',
      status: m['status'] as String? ?? 'Pending',
      tags: (m['tags'] as List<dynamic>? ?? const []).map((tag) => tag as String).toList(),
    );
  }

  static int _legacyPriorityToLevel(String? priority) {
    switch ((priority ?? '').trim().toLowerCase()) {
      case 'low':
        return 1;
      case 'low-medium':
        return 2;
      case 'medium':
        return 3;
      case 'high':
        return 4;
      case 'critical':
        return 5;
      default:
        return 3;
    }
  }

  static int _maskFromDays(List<int> days) {
    var mask = 0;
    for (final day in days) {
      if (day >= DateTime.monday && day <= DateTime.sunday) {
        mask |= 1 << (day - 1);
      }
    }
    return mask;
  }

  @override
  String toString() => 'Task($id, $title)';
}
