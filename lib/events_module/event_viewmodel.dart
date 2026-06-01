import 'event_model.dart';
import 'event_repository.dart';

class EventViewModel {
  EventViewModel._internal();

  static final EventViewModel instance = EventViewModel._internal();

  final EventRepository _repository = EventRepository.instance;

  void seedSample() => _repository.seedSample();

  List<Event> get allEvents => List<Event>.from(_repository.events.value);

  List<Event> get ongoingRoutines {
    final routines = allEvents.where((event) => event.isRecurring).toList();
    routines.sort((left, right) => left.startTime.hour != right.startTime.hour
        ? left.startTime.hour.compareTo(right.startTime.hour)
        : left.startTime.minute.compareTo(right.startTime.minute));
    return routines;
  }

  List<Event> get upcomingEvents {
    final upcoming = allEvents.where((event) => !event.isRecurring).toList();
    upcoming.sort((left, right) => left.startDate.compareTo(right.startDate));
    return upcoming;
  }

  Event? byId(String id) => _repository.byId(id);

  void add(Event event) => _repository.add(event);

  void upsert(Event event) => _repository.upsert(event);

  void remove(String id) => _repository.remove(id);

  List<String> formatRepeatDays(List<int> repeatDays) {
    const labels = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return repeatDays.map((day) => labels[day] ?? '$day').toList();
  }
}