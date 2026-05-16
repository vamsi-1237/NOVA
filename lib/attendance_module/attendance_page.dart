import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nova_app/attendance_module/subject_stat.dart';

class AttendancePage extends StatefulWidget {
  final String timetableJson;

  const AttendancePage({super.key, required this.timetableJson});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<String, List<String>> _parsedTimetable = {};
  List<String> _todaySubjects = [];
  
  // Storage structure: { "YYYY-MM-DD_SubjectName": "Status" }
  final Map<String, String> _dateSubjectStatus = {}; 

  // Maps each subject to: [PresentClasses, TotalClasses]
  final Map<String, List<int>> _subjectStats = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _decodeTimetable();
    _initializeStats();
    _updateSubjectsForDay(_selectedDay!);
  }

  void _decodeTimetable() {
    try {
      final Map<String, dynamic> decoded = jsonDecode(widget.timetableJson);
      _parsedTimetable = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      _parsedTimetable = {};
    }
  }

  void _initializeStats() {
    final Set<String> allSubjects = {};
    for (var subjects in _parsedTimetable.values) {
      allSubjects.addAll(subjects);
    }
    
    for (var subject in allSubjects) {
      _subjectStats[subject] = [0, 0]; 
    }
  }

  void _updateSubjectsForDay(DateTime date) {
    int weekday = date.weekday; 
    String dayKey = 'Day $weekday';

    setState(() {
      if (_parsedTimetable.containsKey(dayKey)) {
        _todaySubjects = _parsedTimetable[dayKey]!;
      } else {
        _todaySubjects = []; 
      }
    });
  }

  String _buildStatusKey(DateTime date, String subject) {
    return "${date.year}-${date.month}-${date.day}_$subject";
  }

  void _updateSubjectMetrics(String subject, String? oldStatus, String? newStatus) {
    if (!_subjectStats.containsKey(subject)) return;

    int presentDelta = 0;
    int totalDelta = 0;

    if (oldStatus == 'Present') {
      presentDelta -= 1;
      totalDelta -= 1;
    } else if (oldStatus == 'Absent') {
      totalDelta -= 1;
    }

    if (newStatus == 'Present') {
      presentDelta += 1;
      totalDelta += 1;
    } else if (newStatus == 'Absent') {
      totalDelta += 1;
    }

    setState(() {
      _subjectStats[subject]![0] += presentDelta; 
      _subjectStats[subject]![1] += totalDelta;   
    });
  }

  double _calculateAttendancePercentage() {
    int totalPresent = 0;
    int totalClasses = 0;

    _subjectStats.forEach((subject, stats) {
      totalPresent += stats[0];
      totalClasses += stats[1];
    });

    if (totalClasses == 0) return 0.0;
    return (totalPresent / totalClasses) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${_calculateAttendancePercentage().toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2026, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _updateSubjectsForDay(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const Divider(height: 20, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _todaySubjects.isEmpty ? 'No Classes Today' : "Today's Schedule",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _todaySubjects.isEmpty
                ? const Center(child: Text('Enjoy your day off!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _todaySubjects.length,
                    itemBuilder: (context, index) {
                      String subject = _todaySubjects[index];
                      String currentStatusKey = _buildStatusKey(_selectedDay!, subject);
                      String currentStatus = _dateSubjectStatus[currentStatusKey] ?? 'Reset';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: InkWell(
                          onTap: () {
                            final stats = _subjectStats[subject] ?? [0, 0];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubjectStatistics(
                                  subjectName: subject,
                                  presentClasses: stats[0],
                                  totalClasses: stats[1],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subject,
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: currentStatus,
                                  items: <String>['Present', 'Absent', 'Cancelled', 'Reset']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue == null || newValue == currentStatus) return;

                                    setState(() {
                                      _updateSubjectMetrics(subject, currentStatus, newValue);

                                      if (newValue == 'Reset') {
                                        _dateSubjectStatus.remove(currentStatusKey);
                                      } else {
                                        _dateSubjectStatus[currentStatusKey] = newValue;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}