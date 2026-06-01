import 'package:flutter/material.dart';

import '../models/schedulable_item.dart';

enum EventCategory { academic, health, fitness, work, productivity, personal, social, finance, other }

enum EventRecurrenceType { none, daily, weekly, monthly, custom }

enum EventImportance { low, medium, high }

enum EventFlexibility { fixed, slightlyFlexible, flexible }

enum EventEnergyRequirement { lowEnergy, mediumEnergy, highFocus }

extension EventCategoryLabel on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.academic:
        return 'Academic';
      case EventCategory.health:
        return 'Health';
      case EventCategory.fitness:
        return 'Fitness';
      case EventCategory.work:
        return 'Work';
      case EventCategory.productivity:
        return 'Productivity';
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.social:
        return 'Social';
      case EventCategory.finance:
        return 'Finance';
      case EventCategory.other:
        return 'Other';
    }
  }
}

extension EventRecurrenceTypeLabel on EventRecurrenceType {
  String get label {
    switch (this) {
      case EventRecurrenceType.none:
        return 'None';
      case EventRecurrenceType.daily:
        return 'Daily';
      case EventRecurrenceType.weekly:
        return 'Weekly';
      case EventRecurrenceType.monthly:
        return 'Monthly';
      case EventRecurrenceType.custom:
        return 'Custom';
    }
  }
}

extension EventImportanceLabel on EventImportance {
  String get label {
    switch (this) {
      case EventImportance.low:
        return 'Low';
      case EventImportance.medium:
        return 'Medium';
      case EventImportance.high:
        return 'High';
    }
  }
}

extension EventFlexibilityLabel on EventFlexibility {
  String get label {
    switch (this) {
      case EventFlexibility.fixed:
        return 'Fixed';
      case EventFlexibility.slightlyFlexible:
        return 'Slightly Flexible';
      case EventFlexibility.flexible:
        return 'Flexible';
    }
  }
}

extension EventEnergyRequirementLabel on EventEnergyRequirement {
  String get label {
    switch (this) {
      case EventEnergyRequirement.lowEnergy:
        return 'Low Energy';
      case EventEnergyRequirement.mediumEnergy:
        return 'Medium Energy';
      case EventEnergyRequirement.highFocus:
        return 'High Focus';
    }
  }
}

class Event extends SchedulableItem {
  Event({
    required super.id,
    required super.title,
    super.isEvent = true,
    required super.category,
    required super.deadline,
    required super.durationMins,
    super.bufferAfterMins = 0,
    super.earliestStart,
    required super.userPriority,
    super.impactScore,
    super.isFixed = true,
    super.recurrenceMask = 0,
    super.isRecurring = false,
    super.energyRequired = 3,
    super.moodTag = '',
    required super.location,
    super.description = '',
    super.status = 'Scheduled',
    super.tags = const [],
  });

  String get categoryLabel => category;

  EventCategory get categoryEnum {
    switch (category.trim().toLowerCase()) {
      case 'academic':
        return EventCategory.academic;
      case 'health':
        return EventCategory.health;
      case 'fitness':
        return EventCategory.fitness;
      case 'work':
        return EventCategory.work;
      case 'productivity':
        return EventCategory.productivity;
      case 'personal':
        return EventCategory.personal;
      case 'social':
        return EventCategory.social;
      case 'finance':
        return EventCategory.finance;
      case 'other':
      default:
        return EventCategory.other;
    }
  }

  String get importanceLabel => priorityText;

  EventImportance get importance {
    switch (userPriority.clamp(1, 5)) {
      case 1:
      case 2:
        return EventImportance.low;
      case 3:
        return EventImportance.medium;
      case 4:
      case 5:
      default:
        return EventImportance.high;
    }
  }

  String get flexibilityLabel => isFixed ? 'Fixed' : 'Flexible';

  EventFlexibility get flexibility {
    if (isFixed) return EventFlexibility.fixed;
    if (bufferAfterMins >= 20) return EventFlexibility.slightlyFlexible;
    return EventFlexibility.flexible;
  }

  String get energyRequirementLabel {
    switch (energyRequired.clamp(1, 5)) {
      case 1:
      case 2:
        return 'Low Energy';
      case 3:
      case 4:
        return 'Medium Energy';
      case 5:
      default:
        return 'High Focus';
    }
  }

  DateTime get startDate => DateTime(deadline.year, deadline.month, deadline.day);

  TimeOfDay get startTime => TimeOfDay(hour: deadline.hour, minute: deadline.minute);

  DateTime? get endDate => durationMins <= 0 ? null : deadline.add(Duration(minutes: durationMins));

  TimeOfDay? get endTime {
    final end = endDate;
    if (end == null) return null;
    return TimeOfDay(hour: end.hour, minute: end.minute);
  }

  EventEnergyRequirement get energyRequirement {
    switch (energyRequired.clamp(1, 5)) {
      case 1:
      case 2:
        return EventEnergyRequirement.lowEnergy;
      case 3:
      case 4:
        return EventEnergyRequirement.mediumEnergy;
      case 5:
      default:
        return EventEnergyRequirement.highFocus;
    }
  }

  EventRecurrenceType get repeatType {
    if (!isRecurring || recurrenceMask == 0) return EventRecurrenceType.none;
    if (recurrenceMask == 127) return EventRecurrenceType.daily;
    final dayCount = recurrenceDays.length;
    if (dayCount == 1) return EventRecurrenceType.weekly;
    if (dayCount == 7) return EventRecurrenceType.daily;
    return EventRecurrenceType.custom;
  }

  List<int> get repeatDays => recurrenceDays;

  String get repeatTypeLabel {
    if (!isRecurring || recurrenceMask == 0) return 'None';
    if (recurrenceMask == 127) return 'Daily';
    final dayCount = recurrenceDays.length;
    if (dayCount == 1) return 'Weekly';
    if (dayCount == 7) return 'Daily';
    return 'Custom';
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
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
    String? status,
    List<String>? tags,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
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
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isEvent': isEvent,
        'category': category,
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
        'description': description,
        'status': status,
        'tags': tags,
      };

  factory Event.fromMap(Map<String, dynamic> map) {
    final recurrenceMask = (map['recurrenceMask'] as int?) ?? _maskFromLegacyRepeatDays(map['repeatDays'] as List<dynamic>?);
    final deadlineString = map['deadline'] as String? ?? map['startDate'] as String?;
    final startMinutes = map['startTimeMinutes'] as int?;
    final fallbackDeadline = deadlineString != null
        ? DateTime.parse(deadlineString)
        : DateTime.now().add(const Duration(hours: 1));
    final deadline = startMinutes == null ? fallbackDeadline : DateTime(
      fallbackDeadline.year,
      fallbackDeadline.month,
      fallbackDeadline.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );

    final durationMins = (map['durationMins'] as int?) ?? _legacyDurationMinutes(map);
    final userPriority = (map['userPriority'] as int?) ?? _legacyImportanceToPriority(map['importance'] as String?);
    final category = map['category'] as String? ?? 'Other';
    return Event(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: category,
      deadline: deadline,
      durationMins: durationMins,
      bufferAfterMins: map['bufferAfterMins'] as int? ?? 0,
      earliestStart: map['earliestStart'] == null ? null : DateTime.parse(map['earliestStart'] as String),
      userPriority: userPriority,
      impactScore: (map['impactScore'] as num?)?.toDouble(),
      isFixed: map['isFixed'] as bool? ?? _legacyFlexibilityToFixed(map['flexibility'] as String?),
      recurrenceMask: recurrenceMask,
      isRecurring: map['isRecurring'] as bool? ?? recurrenceMask != 0,
      energyRequired: map['energyRequired'] as int? ?? _legacyEnergyToLevel(map['energyRequirement'] as String?),
      moodTag: map['moodTag'] as String? ?? '',
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? 'Scheduled',
      tags: (map['tags'] as List<dynamic>? ?? const []).map((tag) => tag as String).toList(),
    );
  }

  static int _maskFromLegacyRepeatDays(List<dynamic>? values) {
    final days = values?.map((day) => day as int).toList() ?? const <int>[];
    var mask = 0;
    for (final day in days) {
      if (day >= DateTime.monday && day <= DateTime.sunday) {
        mask |= 1 << (day - 1);
      }
    }
    return mask;
  }

  static int _legacyDurationMinutes(Map<String, dynamic> map) {
    final endMinutes = map['endTimeMinutes'] as int?;
    final startMinutes = map['startTimeMinutes'] as int?;
    if (endMinutes == null || startMinutes == null) return 60;
    final diff = endMinutes - startMinutes;
    return diff <= 0 ? 60 : diff;
  }

  static int _legacyImportanceToPriority(String? importance) {
    switch ((importance ?? '').trim().toLowerCase()) {
      case 'low':
        return 2;
      case 'high':
        return 5;
      case 'medium':
      default:
        return 3;
    }
  }

  static bool _legacyFlexibilityToFixed(String? flexibility) {
    return (flexibility ?? '').trim().toLowerCase() == 'fixed';
  }

  static int _legacyEnergyToLevel(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'lowenergy':
      case 'low energy':
        return 1;
      case 'highfocus':
      case 'high focus':
        return 5;
      case 'mediumenergy':
      case 'medium energy':
      default:
        return 3;
    }
  }
}