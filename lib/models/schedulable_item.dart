enum ActivityType { learning, practice, routine }

ActivityType activityTypeFromCategory(String category) {
  final normalized = category.trim().toLowerCase();
  if (normalized.contains('learn') || normalized.contains('study') || normalized.contains('academic')) {
    return ActivityType.learning;
  }
  if (normalized.contains('practice') || normalized.contains('coding') || normalized.contains('project') || normalized.contains('work') || normalized.contains('placement')) {
    return ActivityType.practice;
  }
  return ActivityType.routine;
}

String activityTypeLabel(ActivityType type) {
  switch (type) {
    case ActivityType.learning:
      return 'Learning';
    case ActivityType.practice:
      return 'Practice';
    case ActivityType.routine:
      return 'Routine';
  }
}

String priorityLabelFromLevel(int level) {
  switch (level.clamp(1, 5)) {
    case 1:
      return 'Low';
    case 2:
      return 'Low-Medium';
    case 3:
      return 'Medium';
    case 4:
      return 'High';
    case 5:
    default:
      return 'Critical';
  }
}

int _maskFromDays(List<int> days) {
  var mask = 0;
  for (final day in days) {
    if (day >= DateTime.monday && day <= DateTime.sunday) {
      mask |= 1 << (day - 1);
    }
  }
  return mask;
}

List<int> _daysFromMask(int mask) {
  final days = <int>[];
  for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
    if (mask & (1 << (day - 1)) != 0) {
      days.add(day);
    }
  }
  return days;
}

abstract class SchedulableItem {
  final String id;
  final String title;
  final bool isEvent;
  final String category;
  final DateTime deadline;
  final int durationMins;
  final int bufferAfterMins;
  final DateTime? earliestStart;
  final int userPriority;
  final double impactScore;
  final bool isFixed;
  final int recurrenceMask;
  final bool isRecurring;
  final int energyRequired;
  final String moodTag;
  final String location;
  final String description;
  final String status;
  final List<String> tags;

  SchedulableItem({
    required this.id,
    required this.title,
    required this.isEvent,
    required this.category,
    required this.deadline,
    required this.durationMins,
    required this.bufferAfterMins,
    this.earliestStart,
    required this.userPriority,
    double? impactScore,
    required this.isFixed,
    required this.recurrenceMask,
    bool? isRecurring,
    required this.energyRequired,
    required this.moodTag,
    required this.location,
    this.description = '',
    this.status = 'Pending',
    this.tags = const [],
  })  : impactScore = impactScore ?? _deriveImpactScore(
          userPriority: userPriority,
          durationMins: durationMins,
          bufferAfterMins: bufferAfterMins,
          isFixed: isFixed,
          isRecurring: _resolveIsRecurring(recurrenceMask, isRecurring),
          energyRequired: energyRequired,
        ),
        isRecurring = _resolveIsRecurring(recurrenceMask, isRecurring);

  String get name => title;

  Duration get estimatedDuration => Duration(minutes: durationMins);

  String get priority => priorityLabelFromLevel(userPriority);

  double get priorityWeight => userPriority.clamp(1, 5) / 5.0;

  double get deadlinePressure {
    final minutesUntilDeadline = deadline.difference(DateTime.now()).inMinutes;
    final bounded = minutesUntilDeadline.clamp(0, 60 * 24 * 30).toDouble();
    return 1.0 / (1.0 + (bounded / (60.0 * 24.0)));
  }

  double get durationWeight {
    final scaled = durationMins <= 0 ? 0.0 : (durationMins / 240.0);
    return scaled.clamp(0.0, 1.0);
  }

  ActivityType get activityType => activityTypeFromCategory(category);

  double get activityTypeWeight {
    switch (activityType) {
      case ActivityType.learning:
        return 1.0;
      case ActivityType.practice:
        return 0.85;
      case ActivityType.routine:
        return 0.7;
    }
  }

  double get urgencyCoefficient {
    final fixedBonus = isFixed ? 1.08 : 1.0;
    final recurringBonus = isRecurring ? 0.96 : 1.0;
    final locationBonus = location.trim().isEmpty ? 0.98 : 1.0;
    final bufferPenalty = bufferAfterMins <= 0 ? 1.0 : (1.0 - (bufferAfterMins / (durationMins + bufferAfterMins)).clamp(0.0, 0.35));
    final base = (impactScore * 0.4) + (priorityWeight * 0.25) + (deadlinePressure * 0.25) + (activityTypeWeight * 0.1);
    return (base * fixedBonus * recurringBonus * locationBonus * bufferPenalty).clamp(0.0, 1.0);
  }

  double get scheduleScore {
    final deadlinePart = deadlinePressure * 40.0;
    final priorityPart = priorityWeight * 30.0;
    final durationPart = (1.0 - durationWeight) * 10.0;
    final urgencyPart = urgencyCoefficient * 15.0;
    final locationPart = location.trim().isEmpty ? 0.0 : 3.0;
    final activityPart = activityTypeWeight * 2.0;
    return deadlinePart + priorityPart + durationPart + urgencyPart + locationPart + activityPart;
  }

  int get deadlineEpochMillis => deadline.millisecondsSinceEpoch;

  int get locationWeight => location.trim().isEmpty ? 0 : 1;

  List<int> get recurrenceDays => _daysFromMask(recurrenceMask);

  int get recurrenceMaskFromDays => _maskFromDays(recurrenceDays);

  String get activityTypeText => activityTypeLabel(activityType);

  String get priorityText => priority;

  String get statusText => status;

  static double _deriveImpactScore({
    required int userPriority,
    required int durationMins,
    required int bufferAfterMins,
    required bool isFixed,
    required bool isRecurring,
    required int energyRequired,
  }) {
    final priorityComponent = userPriority.clamp(1, 5) / 5.0;
    final durationComponent = (durationMins <= 0 ? 0.0 : (durationMins / 240.0)).clamp(0.0, 1.0);
    final bufferComponent = 1.0 - ((bufferAfterMins <= 0 ? 0.0 : bufferAfterMins / (durationMins + bufferAfterMins)).clamp(0.0, 0.5));
    final fixedComponent = isFixed ? 0.12 : 0.0;
    final recurringComponent = isRecurring ? 0.05 : 0.0;
    final energyComponent = energyRequired.clamp(1, 5) / 25.0;
    return (priorityComponent * 0.45) + (durationComponent * 0.15) + (bufferComponent * 0.15) + fixedComponent + recurringComponent + energyComponent;
  }

  static bool _resolveIsRecurring(int recurrenceMask, bool? isRecurring) {
    return isRecurring ?? recurrenceMask != 0;
  }
}

int compareSchedulableItems(SchedulableItem left, SchedulableItem right) {
  final deadlineCompare = left.deadline.compareTo(right.deadline);
  if (deadlineCompare != 0) return deadlineCompare;

  final priorityCompare = right.userPriority.compareTo(left.userPriority);
  if (priorityCompare != 0) return priorityCompare;

  final durationCompare = left.durationMins.compareTo(right.durationMins);
  if (durationCompare != 0) return durationCompare;

  final urgencyCompare = right.urgencyCoefficient.compareTo(left.urgencyCoefficient);
  if (urgencyCompare != 0) return urgencyCompare;

  final locationCompare = right.locationWeight.compareTo(left.locationWeight);
  if (locationCompare != 0) return locationCompare;

  return left.activityType.index.compareTo(right.activityType.index);
}